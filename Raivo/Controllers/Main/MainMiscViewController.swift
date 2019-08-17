//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit
import Eureka
import CloudKit
import RealmSwift
import MessageUI

class MainMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    private var miscellaneousForm: MiscellaneousForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        miscellaneousForm = MiscellaneousForm(form).build(controller: self)
        
        // Set default/prefilled values
        if let inactivityLockString = StorageHelper.shared.getLockscreenTimeout() {
            miscellaneousForm!.inactivityLockRow.value = MiscellaneousInactivityLockFormOption.build(inactivityLockString)
        }
        
        if let iconsEffect = StorageHelper.shared.getIconsEffect() {
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if let error = error {
            log.error(error)
            BannerHelper.error(error.localizedDescription)
        } else {
            log.verbose("Now wait a moment, sending mails with attatchments can take a few seconds!")
            BannerHelper.success("You should receive a mail within a few minutes!", seconds: 2.0)
        }
    }
        
}
