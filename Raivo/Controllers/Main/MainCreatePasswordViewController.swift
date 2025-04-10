//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit
import Eureka
import RealmSwift
import OneTimePassword
import Base32
import CloudKit

class MainCreatePasswordViewController: FormViewController {
    
    private var passwordForm: PasswordForm?
    
    public var token: Token? = nil
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordForm = PasswordForm(form).build(self)
        
        // Set default/prefilled values
        if let token = token {
            passwordForm?.issuerRow.value = token.issuer
            passwordForm?.accountRow.value = token.name
            passwordForm?.secretRow.value = MF_Base32Codec.base32String(from: token.generator.secret)
            passwordForm?.algorithmRow.value = TokenHelper.shared.getPasswordAlgorithmFromToken(token: token)
            passwordForm?.digitsRow.value = PasswordDigitsFormOption.build(token.generator.digits)!
            passwordForm?.kindRow.value = TokenHelper.shared.getPasswordKindFromToken(token: token)
       
            switch token.generator.factor {
            case .counter(let counterValue):
                passwordForm?.counterRow.value = Int(counterValue)
            case .timer(let timerInterval):
                passwordForm?.timerRow.value = Int(timerInterval)
            }
        } else {
            passwordForm?.algorithmRow.value = PasswordAlgorithmFormOption.OPTION_SHA1
            passwordForm?.digitsRow.value = PasswordDigitsFormOption.OPTION_6_DIGITS
            passwordForm?.kindRow.value = PasswordKindFormOption.OPTION_TOTP
            passwordForm?.timerRow.value = 30
        }
    }
  
    @IBAction func onSave(_ sender: Any) {
        let saveButtonBackup = displayNavBarActivity()
        
        guard passwordForm!.inputIsValid() else {
            dismissNavBarActivity(saveButtonBackup)
            return
        }
        
        let password = createPasswordFromForm()
        var successfullySaved = false
        
        autoreleasepool {
            if let realm = try? RealmHelper.shared.getRealm() {
                try? RealmHelper.shared.writeBlock(realm) {
                    realm.add(password)
                    successfullySaved = true
                }
            }
        }
        
        dismissNavBarActivity(saveButtonBackup)
        
        guard successfullySaved else {
            return
        }
        
        // Pop back to the password list
        let viewControllers = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    private func createPasswordFromForm() -> Password {
        let password = Password()
                
        password.id = password.getNewPrimaryKey()
        password.issuer = passwordForm!.issuerRow.value!.trimmingCharacters(in: .whitespacesAndNewlines)
        password.account = (passwordForm!.accountRow.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        password.iconType = passwordForm!.iconRow.iconType ?? ""
        password.iconValue = passwordForm!.iconRow.iconValue ?? ""
        password.secret = passwordForm!.secretRow.value!
        password.algorithm = passwordForm!.algorithmRow.value!.value
        password.digits = passwordForm!.digitsRow.value!.value
        password.kind = passwordForm!.kindRow.value!.value
        password.timer = passwordForm!.timerRow.value ?? 0
        password.counter = passwordForm!.counterRow.value ?? 0
        password.syncing = SyncerHelper.shared.getSyncer().recordsRequireSync
        password.synced = !SyncerHelper.shared.getSyncer().recordsRequireSync
        
        return password
    }

}
