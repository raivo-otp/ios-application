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
import CloudKit
import RealmSwift
import MessageUI

class MainMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    private var miscellaneousForm: MiscellaneousForm?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = false
        
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
            log.error(error.localizedDescription)
            BannerHelper.error(error.localizedDescription)
        } else {
            switch result {
            case .sent:
                log.verbose("ZIP archive export mail sent successfully")
                BannerHelper.success("You should receive a mail within a few minutes!")
            case .failed:
                log.verbose("Could not send mail due to MFMailComposeResult failure.")
                BannerHelper.success("Something went wrong while sending the mail!")
            default:
                break
            }
        }
    }
        
}
