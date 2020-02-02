//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

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

            if let error = password.syncErrorDescription {
                passwordForm?.errorRow.title = error
                passwordForm?.synchronizationSection.hidden = false
                passwordForm?.synchronizationSection.evaluateHidden()
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        let saveButtonBackup = displayNavBarActivity()
        
        guard passwordForm!.inputIsValid() else {
            dismissNavBarActivity(saveButtonBackup)
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
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
        }
        
        dismissNavBarActivity(saveButtonBackup)
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
