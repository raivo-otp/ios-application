//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import UIKit
import RealmSwift
import Spring

class MainChangePincodeViewController: UIViewController, UIPincodeFieldDelegate {
 
    @IBOutlet weak var pincodeDigitsView: UIPincodeField!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    private var initialPincode: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        self.pincodeDigitsView.delegate = self
        self.showPincodeView("Choose a new PIN code", "You need it to unlock Raivo, so make sure you'll be able to remember it.", focus: false)
    }
    
    // Bugfix for grey shadow under navigation bar
    // https://stackoverflow.com/a/25421617/2491049
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.backgroundColor = UIColor.white
    }

    // Bugfix for grey shadow under navigation bar
    // https://stackoverflow.com/a/25421617/2491049
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pincodeDigitsView.becomeFirstResponder()
    }
    
    func showPincodeView(_ title: String, _ extra: String, focus: Bool = true, flash: Bool = false) {
        self.viewTitle.text = title
        self.viewExtra.text = extra
        
        self.pincodeDigitsView.reset()
      
        if flash {
            self.viewExtra.delay = CGFloat(0.25)
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
        }
        
        if focus {
            pincodeDigitsView.becomeFirstResponder()
        }
    }
    
    func onPincodeComplete(pincode: String) {
        
        DispatchQueue.main.async {
            let salt = StorageHelper.shared.getEncryptionPassword()!
            
            if self.initialPincode == nil {
                self.pincodeDigitsView.reset()
                self.pincodeDigitsView.becomeFirstResponder()
                self.initialPincode = KeyDerivationHelper.derivePincode(pincode, salt)
                self.showPincodeView("Almost there!", "Confirm your PIN code to continue (you'll be signed out after this step).")
            } else {
                if self.initialPincode == KeyDerivationHelper.derivePincode(pincode, salt) {
                    self.changePincode(pincode, salt)
                } else {
                    self.initialPincode = nil
                    self.pincodeDigitsView.reset()
                    self.pincodeDigitsView.becomeFirstResponder()
                    self.showPincodeView("Oh oh, not similar :/", "Please start over by choosing a new PIN code.", flash: true)
                }
            }
        }
    }
    
    private func changePincode(_ pincode: String, _ salt: String) {
        let newKey = KeyDerivationHelper.derivePincode(pincode, salt)
        let newName = RealmHelper.getProposedNewFileName()
        let newFile = RealmHelper.getFileURL(forceFilename: newName)
        
        let oldRealm = try! Realm()
        
        do {
            try oldRealm.writeCopy(toFile: newFile!, encryptionKey: newKey)
        } catch let error {
            log.error(error)
            return
        }
        
        
        if StorageHelper.shared.getBiometricUnlockEnabled() {
            StorageHelper.shared.setEncryptionKey(newKey!.base64EncodedString())
        }
        
        StorageHelper.shared.setRealmFilename(newName)
        StateHelper.shared.reset(dueToPINCodeChange: true)
        
        getAppDelegate().updateStoryboard()
    }
    
}
