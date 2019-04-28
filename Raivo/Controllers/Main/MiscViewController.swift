//
//  MiscViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import CloudKit
import RealmSwift

class MiscViewController: FormViewController {
    
    private var raivoForm: MiscForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raivoForm = MiscForm(form)
        raivoForm!.load(controller: self)
        
        // Set default/prefilled values
        if let inactivityLockString = StorageHelper.settings().string(forKey: StorageHelper.KEY_LOCKSCREEN_TIMEOUT) {
            (form.rowBy(tag: "inactivity_lock") as! PickerInlineRow<MiscInactivityLockOption>).value = getInactivityLockValue(Int(inactivityLockString)!)
        }
        
        SyncerHelper.getSyncer().getAccount(success: accountSuccess, error: accountError)
    }
    
    private func getInactivityLockValue(_ seconds: Int) -> MiscInactivityLockOption {
        for option in MiscInactivityLockOption.options {
            if option.seconds == seconds {
                return option
            }
        }
        
        return MiscInactivityLockOption.defaultOption
    }
    
    private func accountSuccess(_ account: SyncerAccount, _ syncerID: String) {
        DispatchQueue.main.async {
            let accountRow = (self.form.rowBy(tag: "account") as! LabelRow)
            let providerRow = (self.form.rowBy(tag: "provider") as! LabelRow)
            let section = (self.form.sectionBy(tag: "synchronization")!)

            accountRow.value = account.accountName
            providerRow.value = account.serviceName
            
            if syncerID == OfflineSyncer.UNIQUE_ID {
                section.footer = HeaderFooterView(title: "Synchronization is currently disabled.")
            } else {
                section.footer = HeaderFooterView(title: "Raivo uses your " + account.serviceName + " account to store OTP records (encrypted using your encryption key).")
            }

            accountRow.reload()
            providerRow.reload()
            section.reload()
        }
    }
    
    private func accountError(_ error: Error, _ syncerID: String) {
        DispatchQueue.main.async {
            let accountRow = (self.form.rowBy(tag: "account") as! LabelRow)
            let providerRow = (self.form.rowBy(tag: "provider") as! LabelRow)
            let section = (self.form.sectionBy(tag: "synchronization")!)

            accountRow.value = "Unknown (syncing service N/A)"
            providerRow.value = "None (syncing service N/A)"
            section.footer = HeaderFooterView(title: error.localizedDescription)

            accountRow.reload()
            providerRow.reload()
            section.reload()
        }
    }
        
}
