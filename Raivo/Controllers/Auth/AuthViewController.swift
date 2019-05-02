//
//  AuthViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import RealmSwift
import Spring

class AuthViewController: UIViewController, PincodeDigitsProtocol {
    
    @IBOutlet weak var pincodeDigitsView: PincodeDigitsView!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    final let maximumTries = 6
    
    final let lockoutTime = 3.0
    
    var didTryTouchID = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        let biometrics = Bool(StorageHelper.settings().string(forKey: StorageHelper.KEY_TOUCHID_ENABLED) ?? "false")!
        
        self.pincodeDigitsView.showBiometrics(biometrics)
        self.pincodeDigitsView.delegate = self
        self.showPincodeView("Enter your PIN code to continue.")
    }
                                                                                                                                                                                                              
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if getAppDelagate().previousStoryboardName == nil {
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
        let salt = StorageHelper.settings().string(forKey: StorageHelper.KEY_PASSWORD)!
        
        let encryptionKey = KeyDerivationHelper.derivePincode(pincode, salt)
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPincode() else {
                self.pincodeDigitsView.resetAndFocus()
                self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
                return
            }
            
            if isCorrect {
                self.getAppDelagate().updateEncryptionKey(encryptionKey)
                
                self.resetPincodeTries()
                self.updateStoryboard()
            } else {
                self.pincodeDigitsView.resetAndFocus()
                let message = self.getTriesLeft() == 0 ? "Invalid PIN code. That was your last try." : "Invalid PIN code. " + String(self.getTriesLeft()) + " tries left."
                self.showPincodeView(message, flash: true)
            }
        }
    }
    
    internal func resetPincodeTries() {
        StorageHelper.settings().set(string: "0", forKey: StorageHelper.KEY_PINCODE_TRIED_TIMESTAMP)
        StorageHelper.settings().set(string: "0", forKey:  StorageHelper.KEY_PINCODE_TRIED_AMOUNT)
    }
    
    internal func getTriesLeft() -> Int {
        return maximumTries - Int(StorageHelper.settings().string(forKey: StorageHelper.KEY_PINCODE_TRIED_AMOUNT) ?? "0")!
    }
    
    internal func getSecondsLeft() -> Int {
        let lastTryTimestamp = Double(StorageHelper.settings().string(forKey: StorageHelper.KEY_PINCODE_TRIED_TIMESTAMP) ?? "0")!
        return Int((lastTryTimestamp + (lockoutTime * 60)) - Date().timeIntervalSince1970)
    }
    
    internal func tryNewPincode(increase: Bool = true) -> Bool {
        let currentTries = Int(StorageHelper.settings().string(forKey: StorageHelper.KEY_PINCODE_TRIED_AMOUNT) ?? "0")!
        let lastTryTimestamp = Double(StorageHelper.settings().string(forKey: StorageHelper.KEY_PINCODE_TRIED_TIMESTAMP) ?? "0")!
        
        // If can try
        guard currentTries >= maximumTries else {
            if increase {
                StorageHelper.settings().set(string: String(Date().timeIntervalSince1970), forKey: StorageHelper.KEY_PINCODE_TRIED_TIMESTAMP)
                StorageHelper.settings().set(string: String(currentTries + 1), forKey: StorageHelper.KEY_PINCODE_TRIED_AMOUNT)
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
        let enabled = Bool(StorageHelper.settings().string(forKey: StorageHelper.KEY_TOUCHID_ENABLED) ?? "false")!
        
        guard enabled else {
            return
        }
        
        guard self.tryNewPincode(increase: false) else {
            self.pincodeDigitsView.resetAndFocus()
            self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
            return
        }
        
        let prompt = "Unlock Raivo in no time"
        let result = StorageHelper.secrets().string(forKey: StorageHelper.KEY_ENCRYPTION_KEY, withPrompt: prompt)
        
        switch result {
        case .success(let key):
            let _ = self.tryNewPincode()
            self.getAppDelagate().updateEncryptionKey(Data(base64Encoded: key))
            self.updateStoryboard()
        default:
            return
        }
    }
}
