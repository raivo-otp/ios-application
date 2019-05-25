//
//  MainMiscViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import Eureka
import CloudKit
import RealmSwift

class MainMiscViewController: FormViewController {
    
    private var miscellaneousForm: MiscellaneousForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self)
        
        // Set default/prefilled values
        if let inactivityLockString = StorageHelper.getLockscreenTimeout() {
            miscellaneousForm!.inactivityLockRow.value = MiscellaneousInactivityLockFormOption.build(inactivityLockString)
        }
        
        if let iconsEffect = StorageHelper.getIconsEffect() {
            miscellaneousForm!.iconsEffectRow.value = MiscellaneousIconsEffectFormOption.build(iconsEffect)
        }
        
        SyncerHelper.shared.getSyncer().getAccount(success: accountSuccess, error: accountError)
        
        miscellaneousForm!.ready()
    }
    
    private func accountSuccess(_ account: SyncerAccount, _ syncerID: String) {
        DispatchQueue.main.async {
            self.miscellaneousForm?.accountRow.value = account.name
            self.miscellaneousForm?.providerRow.value = SyncerHelper.shared.getSyncer().name

            self.miscellaneousForm?.accountRow.reload()
            self.miscellaneousForm?.providerRow.reload()
            self.miscellaneousForm?.synchronizationSection.reload()
        }
    }
    
    private func accountError(_ error: Error, _ syncerID: String) {
        DispatchQueue.main.async {
            self.miscellaneousForm?.accountRow.value = "Unknown (syncing service N/A)"
            self.miscellaneousForm?.providerRow.value = "None (syncing service N/A)"
            self.miscellaneousForm?.synchronizationSection.footer = HeaderFooterView(title: error.localizedDescription)

            self.miscellaneousForm?.accountRow.reload()
            self.miscellaneousForm?.providerRow.reload()
            self.miscellaneousForm?.synchronizationSection.reload()
        }
    }
        
}
