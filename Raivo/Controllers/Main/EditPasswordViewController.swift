//
//  EditPasswordViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

class EditPasswordViewController: FormViewController {
    
    private var raivoForm: PasswordForm?
    
    var password: Password?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raivoForm = PasswordForm(form)
        
        // Set default/prefilled values
        if let password = password {
            (form.rowBy(tag: "issuer") as! TextRow).value = password.issuer
            (form.rowBy(tag: "account") as! TextRow).value = password.account
            (form.rowBy(tag: "secret") as! TextRow).value = password.secret
            (form.rowBy(tag: "algorithm") as! PickerInlineRow<String>).value = password.algorithm
            (form.rowBy(tag: "digits") as! IntRow).value = password.digits
            (form.rowBy(tag: "kind") as! PickerInlineRow<String>).value = password.kind
            
            switch password.kind {
            case Password.Kinds.HOTP:
                (form.rowBy(tag: "counter") as! IntRow).value = password.counter
            default:
                (form.rowBy(tag: "timer") as! IntRow).value = password.timer
            }
            
            if let error = password.syncErrorDescription {
                let synchronization = form.sectionBy(tag: "synchronization")
                synchronization!.hidden = Condition(booleanLiteral: false)
                (form.rowBy(tag: "error") as! LabelRow).title = error
                
                synchronization?.evaluateHidden()
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        let saveButtonBackup = displayNavBarActivity()
        
        if !raivoForm!.isValid() {
            dismissNavBarActivity(saveButtonBackup)
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            updatePasswordFromForm()
        }
        
        dismissNavBarActivity(saveButtonBackup)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updatePasswordFromForm() {
        // Define form field values
        let issuer = (form.rowBy(tag: "issuer") as! TextRow).value!
        let account = (form.rowBy(tag: "account") as! TextRow).value!
        let secret = (form.rowBy(tag: "secret") as! TextRow).value!
        let algorithm = (form.rowBy(tag: "algorithm") as! PickerInlineRow<String>).value!
        let digits = (form.rowBy(tag: "digits") as! IntRow).value!
        let kind = (form.rowBy(tag: "kind") as! PickerInlineRow<String>).value!
        let timer = (form.rowBy(tag: "timer") as! IntRow).value
        let counter = (form.rowBy(tag: "counter") as! IntRow).value
        
        // Set data
        password!.issuer = issuer
        password!.account = account
        password!.secret = secret
        password!.algorithm = algorithm
        password!.digits = digits
        password!.kind = kind
        password!.timer = timer ?? 0
        password!.counter = counter ?? 0
        password!.syncing = true
        password!.synced = false
    }
    
}
