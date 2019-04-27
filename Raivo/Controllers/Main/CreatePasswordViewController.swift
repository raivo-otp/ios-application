//
//  CreatePasswordViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import OneTimePassword
import Base32

class CreatePasswordViewController: FormViewController {
    
    private var raivoForm: PasswordForm?
    
    public var token: Token? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raivoForm = PasswordForm(form)
        
        // Set default/prefilled values
        if let token = token {
            (form.rowBy(tag: "issuer") as! TextRow).value = token.issuer
            (form.rowBy(tag: "account") as! TextRow).value = token.name
            (form.rowBy(tag: "secret") as! TextRow).value = MF_Base32Codec.base32String(from: token.generator.secret)
            (form.rowBy(tag: "algorithm") as! PickerInlineRow<String>).value = TokenHelper.getPasswordAlgorithmFromToken(token: token)
            (form.rowBy(tag: "digits") as! IntRow).value = token.generator.digits
            (form.rowBy(tag: "kind") as! PickerInlineRow<String>).value = TokenHelper.getPasswordKindFromToken(token: token)
            
            switch token.generator.factor {
            case .counter(let counterValue):
                (form.rowBy(tag: "counter") as! IntRow).value = Int(counterValue)
            case .timer(let timerInterval):
                (form.rowBy(tag: "timer") as! IntRow).value = Int(timerInterval)
            }
        } else {
            (form.rowBy(tag: "algorithm") as! PickerInlineRow<String>).value = Password.Algorithms.SHA1
            (form.rowBy(tag: "digits") as! IntRow).value = 6
            (form.rowBy(tag: "kind") as! PickerInlineRow<String>).value = Password.Kinds.TOTP
            (form.rowBy(tag: "timer") as! IntRow).value = 30
        }
    }
  
    @IBAction func onSave(_ sender: Any) {
        let saveButtonBackup = displayNavBarActivity()
        
        if !raivoForm!.isValid() {
            dismissNavBarActivity(saveButtonBackup)
            return
        }
        
        let password = createPasswordFromForm()
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(password, update: true)
        }
        
        dismissNavBarActivity(saveButtonBackup)
        
        // Pop back to the password list
        let viewControllers = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    private func createPasswordFromForm() -> Password {
        // Define form field values
        let issuer = (form.rowBy(tag: "issuer") as! TextRow).value!
        let account = (form.rowBy(tag: "account") as! TextRow).value!
        let secret = (form.rowBy(tag: "secret") as! TextRow).value!
        let algorithm = (form.rowBy(tag: "algorithm") as! PickerInlineRow<String>).value!
        let digits = (form.rowBy(tag: "digits") as! IntRow).value!
        let kind = (form.rowBy(tag: "kind") as! PickerInlineRow<String>).value!
        let timer = (form.rowBy(tag: "timer") as! IntRow).value
        let counter = (form.rowBy(tag: "counter") as! IntRow).value
        
        // Create new password
        let password = Password()
        
        // Set data
        password.id = password.getNewPrimaryKey()
        password.issuer = issuer
        password.account = account
        password.secret = secret
        password.algorithm = algorithm
        password.digits = digits
        password.kind = kind
        password.timer = timer ?? 0
        password.counter = counter ?? 0
        password.syncing = true
        password.synced = false
        
        return password
    }

}
