//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit
import RealmSwift

class AuthEntryViewController: UIViewController, UIPincodeFieldDelegate {
    
    @IBOutlet weak var pincodeField: UIPincodeField!
    
    @IBOutlet weak var biometricLabel: UIButton!
    
    final let maximumTries = 6
    
    final let lockoutTime = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        biometricLabel.isHidden = !StorageHelper.shared.getBiometricUnlockEnabled()
        
        pincodeField.delegate = self
        pincodeField.layoutIfNeeded()
        
        NotificationHelper.shared.listen(to: UIApplication.willEnterForegroundNotification, distinctBy: id(self)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tryBiometricsUnlock()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationHelper.shared.discard(UIApplication.willEnterForegroundNotification, byDistinctName: id(self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if getAppDelegate().previousStoryboardName == StateHelper.Storyboard.LOAD {
            tryBiometricsUnlock()
        } else {
            pincodeField.becomeFirstResponder()
        }
    }
    
    @IBAction func onBiometricsUnlock(_ sender: Any) {
        tryBiometricsUnlock()
    }
    
    func onPincodeComplete(pincode: String) {
        let salt = StorageHelper.shared.getEncryptionPassword()!
        
        guard let encryptionKey = try? CryptographyHelper.shared.derive(pincode, withSalt: salt) else {
            BannerHelper.error("Key derivation failed.") {
                self.pincodeField.reset()
            }
            
            return
        }
        
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPincode() else {
                BannerHelper.error("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.") {
                    self.pincodeField.reset()
                }
                
                return
            }
            
            if isCorrect {
                log.verbose("Unlocked app via pincode")
                
                getAppDelegate().updateEncryptionKey(encryptionKey)
                
                self.resetPincodeTries()
                getAppDelegate().updateStoryboard()
            } else {
                log.verbose("Invalid pincode entered")
                
                self.pincodeField.reset()
                
                let message = self.getTriesLeft() == 0 ? "Invalid PIN code. That was your last try." : "Invalid PIN code. " + String(self.getTriesLeft()) + " tries left."
                
                BannerHelper.error(message, seconds: 1.0)
                return
            }
        }
    }
    
    func onPincodeChange(pincode: String) {
        // Not implemented
    }
    
    internal func resetPincodeTries() {
        StorageHelper.shared.setPincodeTriedAmount(0)
        StorageHelper.shared.setPincodeTriedTimestamp(0)
    }
    
    internal func getTriesLeft() -> Int {
        return maximumTries - (StorageHelper.shared.getPincodeTriedAmount() ?? 0)
    }
    
    internal func getSecondsLeft() -> Int {
        let lastTryTimestamp = StorageHelper.shared.getPincodeTriedTimestamp() ?? TimeInterval(0)
        return Int((lastTryTimestamp + (lockoutTime * 60)) - Date().timeIntervalSince1970)
    }
    
    internal func tryNewPincode(increase: Bool = true) -> Bool {
        let currentTries = StorageHelper.shared.getPincodeTriedAmount() ?? 0
        let lastTryTimestamp = StorageHelper.shared.getPincodeTriedTimestamp() ?? TimeInterval(0)
        
        // If can try
        guard currentTries >= maximumTries else {
            if increase {
                StorageHelper.shared.setPincodeTriedTimestamp(Date().timeIntervalSince1970)
                StorageHelper.shared.setPincodeTriedAmount(currentTries + 1)
            }
            
            return true
        }
        
        // If reset counter required
        guard (lastTryTimestamp + (lockoutTime * 60)) > Date().timeIntervalSince1970 else {
            resetPincodeTries()
            return tryNewPincode()
        }
        
        // If can try
        return false
    }
    
    internal func tryBiometricsUnlock() {
        guard StorageHelper.shared.getBiometricUnlockEnabled() else {
            pincodeField.becomeFirstResponder()
            return
        }
        
        guard self.tryNewPincode(increase: false) else {
            BannerHelper.error("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.") {
                self.pincodeField.reset()
            }
            
            return
        }
        
        pincodeField.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let key = StorageHelper.shared.getEncryptionKey(prompt: "Unlock Raivo in no time") {
                self.resetPincodeTries()
                
                log.verbose("Unlocked app via biometric")
                
                getAppDelegate().updateEncryptionKey(Data(base64Encoded: key))
                getAppDelegate().updateStoryboard()
            } else {
                self.pincodeField.becomeFirstResponder()
            }
        }
    }
}
