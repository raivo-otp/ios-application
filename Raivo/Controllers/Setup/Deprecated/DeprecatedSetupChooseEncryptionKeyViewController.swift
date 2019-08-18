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
import Spring

class DeprecatedSetupChooseEncryptionKeyViewController: UIViewController, UITextFieldDelegate {
    
    public var account: SyncerAccount?
    
    public var challenge: SyncerChallenge?
    
    private var recoveryMode: Bool = false
    
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var viewExtra: SpringLabel!
    
    @IBOutlet weak var viewEncryptionPasswordInitial: UITextField!
    
    @IBOutlet weak var viewEncryptionPasswordConfirm: UITextField!
    
    @IBOutlet weak var forgotView: UIButton!
    
    @IBOutlet weak var continueView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        adjustViewToKeyboard()
        
        viewEncryptionPasswordInitial.delegate = self
        viewEncryptionPasswordConfirm.delegate = self

        if let _ = self.challenge?.challenge {
            viewTitle.text = "Synchronize your data"
            viewExtra.text = "You've used Raivo before. Enter the recovery password you took note of back then."
            forgotView.isHidden = false
            recoveryMode = true
        } else {
            viewEncryptionPasswordConfirm.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewEncryptionPasswordInitial.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case viewEncryptionPasswordInitial:
            viewEncryptionPasswordConfirm.becomeFirstResponder()
            return false
        case viewEncryptionPasswordConfirm:
            onContinue(textField)
            return true
        default:
            return true
        }
    }
    
    private func verifyRecoveryChallenge() -> Bool {
        if let challenge = self.challenge?.challenge {
            do {
                let _ = try CryptographyHelper.shared.decrypt(challenge, withKey: viewEncryptionPasswordInitial.text ?? "")
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
    @IBAction func onContinue(_ sender: Any) {
        guard viewEncryptionPasswordInitial.text?.length ?? 0 >= 8 else {
            self.viewExtra.text = "A stronger/longer password is required."
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
            return
        }
        
        guard recoveryMode || viewEncryptionPasswordInitial.text == viewEncryptionPasswordConfirm.text else {
            self.viewExtra.text = "The password and confirmation do not match."
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
            return
        }
        
        guard !recoveryMode || verifyRecoveryChallenge() else {
            self.viewExtra.text = "The password you entered is incorrect."
            self.viewExtra.animation = "shake"
            self.viewExtra.animate()
            return
        }
        
        StorageHelper.shared.setEncryptionPassword(viewEncryptionPasswordInitial.text!)
        performSegue(withIdentifier: "ChoosePincodeSegue", sender: sender)
    }
}
