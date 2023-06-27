//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit
import Eureka
import RealmSwift

class MainEditPasswordViewController: FormViewController {
    
    private var passwordForm: PasswordForm?
    
    public var password: Password?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordForm = PasswordForm(form).build(self)
        
        // Set default/prefilled values
        if let password = password {
            passwordForm?.issuerRow.value = password.issuer
            passwordForm?.accountRow.value = password.account
            passwordForm?.iconRow.iconType = password.iconType
            passwordForm?.iconRow.iconValue = password.iconValue
            passwordForm?.secretRow.value = password.secret
            passwordForm?.algorithmRow.value = PasswordAlgorithmFormOption.build(password.algorithm)
            passwordForm?.digitsRow.value = PasswordDigitsFormOption.build(password.digits)
            passwordForm?.kindRow.value = PasswordKindFormOption.build(password.kind)
            passwordForm?.counterRow.value = password.counter
            passwordForm?.timerRow.value = password.timer
            
            if password.syncing {
                passwordForm?.errorRow.title = "Syncing in progress, but not completed (if this is unexpected, try resaving the OTP)."
                passwordForm?.synchronizationSection.hidden = false
                passwordForm?.synchronizationSection.evaluateHidden()
            }
            
            if let error = password.syncErrorDescription {
                passwordForm?.errorRow.title = error
                passwordForm?.synchronizationSection.hidden = false
                passwordForm?.synchronizationSection.evaluateHidden()
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        let saveButtonBackup = displayNavBarActivity()
        var successfullySaved = false
        
        guard passwordForm!.inputIsValid() else {
            dismissNavBarActivity(saveButtonBackup)
            return
        }
        
        autoreleasepool {
            if let realm = try? RealmHelper.shared.getRealm() {
                try? RealmHelper.shared.writeBlock(realm) {
                    password!.issuer = passwordForm!.issuerRow.value!.trimmingCharacters(in: .whitespacesAndNewlines)
                    password!.account = (passwordForm!.accountRow.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    password!.iconType = passwordForm!.iconRow.iconType ?? ""
                    password!.iconValue = passwordForm!.iconRow.iconValue ?? ""
                    password!.secret = passwordForm!.secretRow.value!
                    password!.algorithm = passwordForm!.algorithmRow.value!.value
                    password!.digits = passwordForm!.digitsRow.value!.value
                    password!.kind = passwordForm!.kindRow.value!.value
                    password!.timer = passwordForm!.timerRow.value ?? 0
                    password!.counter = passwordForm!.counterRow.value ?? 0
                    password!.syncing = true
                    password!.synced = false
                    successfullySaved = true
                }
            }
        }
        
        dismissNavBarActivity(saveButtonBackup)
        
        if successfullySaved {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
