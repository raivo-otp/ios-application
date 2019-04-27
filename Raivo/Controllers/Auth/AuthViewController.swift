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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        self.pincodeDigitsView.delegate = self
        self.showPincodeView("Enter your PIN code to continue.")
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pincodeDigitsView.focus()
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
    
    func onPincodeComplete(pincode: String) {
        let salt = KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PASSWORD)!
        
        let encryptionKey = KeyDerivationHelper.derivePincode(pincode, salt)
        let isCorrect = RealmHelper.isCorrectEncryptionKey(encryptionKey)
        
        DispatchQueue.main.async {
            guard self.tryNewPincode() else {
                self.pincodeDigitsView.resetAndFocus()
                self.showPincodeView("Please wait " + String(self.getSecondsLeft()) + " seconds and try again.", flash: true)
                return
            }
            
            if isCorrect {
                self.getAppDelagate().encryptionKey = encryptionKey
                
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
        KeychainHelper.settings().set(string: "0", forKey: KeychainHelper.KEY_PINCODE_TRIED_TIMESTAMP)
        KeychainHelper.settings().set(string: "0", forKey:  KeychainHelper.KEY_PINCODE_TRIED_AMOUNT)
    }
    
    internal func getTriesLeft() -> Int {
        return maximumTries - Int(KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PINCODE_TRIED_AMOUNT) ?? "0")!
    }
    
    internal func getSecondsLeft() -> Int {
        let lastTryTimestamp = Double(KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PINCODE_TRIED_TIMESTAMP) ?? "0")!
        return Int((lastTryTimestamp + (lockoutTime * 60)) - Date().timeIntervalSince1970)
    }
    
    internal func tryNewPincode() -> Bool {
        let currentTries = Int(KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PINCODE_TRIED_AMOUNT) ?? "0")!
        let lastTryTimestamp = Double(KeychainHelper.settings().string(forKey: KeychainHelper.KEY_PINCODE_TRIED_TIMESTAMP) ?? "0")!
        
        // If can try
        guard currentTries >= maximumTries else {
            KeychainHelper.settings().set(string: String(Date().timeIntervalSince1970), forKey: KeychainHelper.KEY_PINCODE_TRIED_TIMESTAMP)
            KeychainHelper.settings().set(string: String(currentTries + 1), forKey: KeychainHelper.KEY_PINCODE_TRIED_AMOUNT)
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
    
}
