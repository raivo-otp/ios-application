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
import Valet

class SetupChoosePincodeViewController: UIViewController, UIPincodeFieldDelegate {

    @IBOutlet weak var viewPincode: UIPincodeField!
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    private var initialPincode: Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustConstraintToKeyboard()
        
        viewPincode.delegate = self
        viewPincode.layoutIfNeeded()
        
        showPincodeView("Choose Your PIN code", "You need it to unlock Raivo, so make sure you'll be able to remember it.", focus: false)
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewPincode.becomeFirstResponder()
    }
    
    func showPincodeView(_ title: String, _ extra: String, focus: Bool = true, flash: Bool = false) {
        self.viewTitle.text = title
        self.viewExtra.text = extra
        
        self.viewPincode.reset()
        
        if flash {
            self.viewExtra.delay = CGFloat(0.25)
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
        }
        
        if focus {
            self.viewPincode.becomeFirstResponder()
        }
    }
    
    func onPincodeComplete(pincode: String) {

        DispatchQueue.main.async {
            let salt = StorageHelper.shared.getEncryptionPassword()!
            
            if self.initialPincode == nil {
                self.viewPincode.reset()
                self.viewPincode.becomeFirstResponder()
                self.initialPincode = KeyDerivationHelper.derivePincode(pincode, salt)
                self.showPincodeView("Almost there!", "Confirm your PIN code to continue.")
            } else {
                if self.initialPincode == KeyDerivationHelper.derivePincode(pincode, salt) {
                    self.createDatabase(pincode, salt)
                } else {
                    self.initialPincode = nil
                    self.viewPincode.reset()
                    self.viewPincode.becomeFirstResponder()
                    self.showPincodeView("Oh oh, not similar :/", "Please start over by choosing a new PIN code.", flash: true)
                }
            }
        }
    }
    
    private func createDatabase(_ pincode: String, _ salt: String) {
        getAppDelegate().updateEncryptionKey(KeyDerivationHelper.derivePincode(pincode, salt))

        let _ = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                
        if StorageHelper.shared.canAccessSecrets() {
            performSegue(withIdentifier: "EnableBiometricsSegue", sender: nil)
        } else {
            getAppDelegate().updateStoryboard()
        }
    }
    
}
