//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import UIKit
import RealmSwift

class AuthEntryViewController: UIViewController, UIPasscodeFieldDelegate {
    
    @IBOutlet weak var passcodeField: UIPasscodeField!
    
    @IBOutlet weak var biometricLabel: UIButton!
    
    final let maximumTries = 6
    
    final let lockoutTime = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        biometricLabel.isHidden = !StorageHelper.shared.getBiometricUnlockEnabled()
        
        passcodeField.delegate = self
        passcodeField.layoutIfNeeded()
        
        NotificationHelper.shared.listen(to: UIApplication.willEnterForegroundNotification, distinctBy: id(self)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tryBiometricsUnlock()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        attachKeyboardConstraint(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationHelper.shared.discard(UIApplication.willEnterForegroundNotification, byDistinctName: id(self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if getAppDelegate().previousStoryboardName == StateHelper.Storyboard.LOAD {
            tryBiometricsUnlock()
        } else {
            passcodeField.becomeFirstResponder()
        }
    }
    
    @IBAction func onBiometricsUnlock(_ sender: Any) {
        tryBiometricsUnlock()
    }
    
    func onPasscodeComplete(passcode: String) {
        let salt = StorageHelper.shared.getEncryptionPassword()!
        
        guard let encryptionKey = try? CryptographyHelper.shared.derive(passcode, withSalt: salt) else {
            BannerHelper.error("Key derivation failed.") {
                self.passcodeField.reset()
            }
            
            return
        }
        
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPasscode() else {
                BannerHelper.error("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.") {
                    self.passcodeField.reset()
                }
                
                return
            }
            
            if isCorrect {
                log.verbose("Unlocked app via passcode")
                
                getAppDelegate().updateEncryptionKey(encryptionKey)
                
                self.resetPasscodeTries()
                getAppDelegate().updateStoryboard()
            } else {
                log.verbose("Invalid passcode entered")
                
                self.passcodeField.reset()
                
                let message = self.getTriesLeft() == 0 ? "Invalid passcode. That was your last try." : "Invalid passcode. " + String(self.getTriesLeft()) + " tries left."
                
                BannerHelper.error(message, seconds: 1.0)
                return
            }
        }
    }
    
    func onPasscodeChange(passcode: String) {
        // Not implemented
    }
    
    internal func resetPasscodeTries() {
        StorageHelper.shared.setPasscodeTriedAmount(0)
        StorageHelper.shared.setPasscodeTriedTimestamp(0)
    }
    
    internal func getTriesLeft() -> Int {
        return maximumTries - (StorageHelper.shared.getPasscodeTriedAmount() ?? 0)
    }
    
    internal func getSecondsLeft() -> Int {
        let lastTryTimestamp = StorageHelper.shared.getPasscodeTriedTimestamp() ?? TimeInterval(0)
        return Int((lastTryTimestamp + (lockoutTime * 60)) - Date().timeIntervalSince1970)
    }
    
    internal func tryNewPasscode(increase: Bool = true) -> Bool {
        let currentTries = StorageHelper.shared.getPasscodeTriedAmount() ?? 0
        let lastTryTimestamp = StorageHelper.shared.getPasscodeTriedTimestamp() ?? TimeInterval(0)
        
        // If can try
        guard currentTries >= maximumTries else {
            if increase {
                StorageHelper.shared.setPasscodeTriedTimestamp(Date().timeIntervalSince1970)
                StorageHelper.shared.setPasscodeTriedAmount(currentTries + 1)
            }
            
            return true
        }
        
        // If reset counter required
        guard (lastTryTimestamp + (lockoutTime * 60)) > Date().timeIntervalSince1970 else {
            resetPasscodeTries()
            return tryNewPasscode()
        }
        
        // If can try
        return false
    }
    
    internal func tryBiometricsUnlock() {
        guard StorageHelper.shared.getBiometricUnlockEnabled() else {
            passcodeField.becomeFirstResponder()
            return
        }
        
        guard self.tryNewPasscode(increase: false) else {
            BannerHelper.error("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.") {
                self.passcodeField.reset()
            }
            
            return
        }
        
        passcodeField.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let key = StorageHelper.shared.getEncryptionKey(prompt: "Unlock Raivo in no time") {
                self.resetPasscodeTries()
                
                log.verbose("Unlocked app via biometric")
                
                getAppDelegate().updateEncryptionKey(Data(base64Encoded: key))
                getAppDelegate().updateStoryboard()
            } else {
                self.passcodeField.becomeFirstResponder()
            }
        }
    }
}
