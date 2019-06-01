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
import Spring

class AuthEntryViewController: UIViewController, UIPincodeFieldDelegate {
    
    @IBOutlet weak var viewPincode: UIPincodeField!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    @IBOutlet weak var viewBiometricsUnlock: UIButton!
    
    final let maximumTries = 6
    
    final let lockoutTime = 3.0
    
    var didTryTouchID = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustViewToKeyboard()
        
        viewBiometricsUnlock.isHidden = !StorageHelper.shared.getBiometricUnlockEnabled()
        
        viewPincode.delegate = self
        viewPincode.layoutIfNeeded()
        
        showPincodeView("Enter your PIN code to continue.")
        
        NotificationHelper.shared.listen(to: UIApplication.willEnterForegroundNotification, distinctBy: id(self)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tryBiometricsUnlock()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationHelper.shared.discard(UIApplication.willEnterForegroundNotification, byDistinctName: id(self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if getAppDelegate().previousStoryboardName == StateHelper.Storyboard.LOAD {
            tryBiometricsUnlock()
        } else {
            viewPincode.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        didTryTouchID = false
    }
    
    func showPincodeView(_ extra: String, flash: Bool = false) {
        viewPincode.reset()
        viewExtra.text = extra
        
        if flash {
            self.viewExtra.delay = CGFloat(0.25)
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
        }
    }
    
    @IBAction func onBiometricsUnlock(_ sender: Any) {
        tryBiometricsUnlock()
    }
    
    func onPincodeComplete(pincode: String) {
        let salt = StorageHelper.shared.getEncryptionPassword()!
        
        guard let encryptionKey = try? CryptographyHelper.shared.derive(pincode, withSalt: salt) else {
            showPincodeView("Key derivation failed.")
            return
        }
        
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPincode() else {
                self.viewPincode.reset()
                self.viewPincode.becomeFirstResponder()
                self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
                return
            }
            
            if isCorrect {
                getAppDelegate().updateEncryptionKey(encryptionKey)
                
                self.resetPincodeTries()
                getAppDelegate().updateStoryboard()
            } else {
                self.viewPincode.reset()
                self.viewPincode.becomeFirstResponder()
                
                let message = self.getTriesLeft() == 0 ? "Invalid PIN code. That was your last try." : "Invalid PIN code. " + String(self.getTriesLeft()) + " tries left."
                self.showPincodeView(message, flash: true)
            }
        }
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
            viewPincode.becomeFirstResponder()
            return
        }
        
        guard self.tryNewPincode(increase: false) else {
            viewPincode.reset()
            showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
            return
        }
        
        viewPincode.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let key = StorageHelper.shared.getEncryptionKey(prompt: "Unlock Raivo in no time") {
                self.resetPincodeTries()
                
                getAppDelegate().updateEncryptionKey(Data(base64Encoded: key))
                getAppDelegate().updateStoryboard()
            } else {
                self.viewPincode.becomeFirstResponder()
            }
        }
    }
}
