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

class AuthEntryViewController: UIViewController, PincodeDigitsProtocol {
    
    @IBOutlet weak var pincodeDigitsView: PincodeDigitsView!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    final let maximumTries = 6
    
    final let lockoutTime = 3.0
    
    var didTryTouchID = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        self.pincodeDigitsView.showBiometrics(StorageHelper.shared.getBiometricUnlockEnabled())
        self.pincodeDigitsView.delegate = self
        self.showPincodeView("Enter your PIN code to continue.")
    }

    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if getAppDelegate().previousStoryboardName == StateHelper.Storyboard.LOAD {
            self.tryTouchID()
        }
        
        self.pincodeDigitsView.focus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        didTryTouchID = false
    }
    
    func showPincodeView(_ extra: String, focus: Bool = true, flash: Bool = false) {
        self.viewExtra.text = extra
        
        if focus {
            self.pincodeDigitsView.resetAndFocus()
        } else {
            self.pincodeDigitsView.reset()
        }
        
        if flash {
            self.viewExtra.delay = CGFloat(0.25)
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
        }
    }
    
    func onBiometricsTrigger() {
        self.tryTouchID()
    }
    
    func onPincodeComplete(pincode: String) {
        let salt = StorageHelper.shared.getEncryptionPassword()!
        
        let encryptionKey = KeyDerivationHelper.derivePincode(pincode, salt)
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPincode() else {
                self.pincodeDigitsView.resetAndFocus()
                self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
                return
            }
            
            if isCorrect {
                getAppDelegate().updateEncryptionKey(encryptionKey)
                
                self.resetPincodeTries()
                getAppDelegate().updateStoryboard()
            } else {
                self.pincodeDigitsView.resetAndFocus()
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
    
    internal func tryTouchID() {
        guard StorageHelper.shared.getBiometricUnlockEnabled() else {
            return
        }
        
        guard self.tryNewPincode(increase: false) else {
            self.pincodeDigitsView.resetAndFocus()
            self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
            return
        }
        
        if let key = StorageHelper.shared.getEncryptionKey(prompt: "Unlock Raivo in no time") {
            getAppDelegate().updateEncryptionKey(Data(base64Encoded: key))
            self.resetPincodeTries()
            getAppDelegate().updateStoryboard()
        } else {
            let _ = self.tryNewPincode()
        }
        
    }
}
