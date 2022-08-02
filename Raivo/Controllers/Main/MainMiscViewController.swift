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
import CloudKit
import RealmSwift
import MessageUI

class MainMiscViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    private var miscellaneousForm: MiscellaneousForm?

    /// The Realm result set of unsynced passwords
    var unsyncedPasswords: Results<Password>?
    
    /// The Realm token to observe password sync changes
    var syncStatusToken: NotificationToken?

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
        
        if let realm = RealmHelper.shared.getRealm() {
            unsyncedPasswords = realm.objects(Password.self).filter("synced == 0 or syncing == 1")
            
        }
        
        miscellaneousForm!.ready()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSyncingStatus()
        
        syncStatusToken = unsyncedPasswords?.observe { RealmCollectionChange in
            self.updateSyncingStatus()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        syncStatusToken?.invalidate()
    }
    
    private func updateSyncingStatus() {
        let unsyncedPasswordsCount = self.unsyncedPasswords?.count ?? 0
        
        if SyncerHelper.shared.getSyncer().name == SyncerHelper.shared.getSyncer(id(OfflineSyncer.self)).name {
            self.miscellaneousForm?.statusRow.value = "None (offline)"
        } else if unsyncedPasswordsCount == 1 {
            self.miscellaneousForm?.statusRow.value = "1 unsynced OTP"
        } else if unsyncedPasswordsCount > 1 {
            self.miscellaneousForm?.statusRow.value = String(unsyncedPasswordsCount) + " unsynced OTP's"
        } else {
            self.miscellaneousForm?.statusRow.value = "Syncing up-to-date"
        }
        
        self.miscellaneousForm?.statusRow.updateCell()
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
            self.miscellaneousForm?.providerRow.value = "Unknown (syncing service N/A)"
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
            BannerHelper.shared.error("Something went wrong", error.localizedDescription, wrapper: view)
        } else {
            switch result {
            case .sent:
                log.verbose("ZIP archive export mail sent successfully")
                BannerHelper.shared.done("Hold tight", "Sending the mail takes a few minutes", duration: 3.0, wrapper: view)
            case .failed:
                log.verbose("Could not send mail due to MFMailComposeResult failure.")
                BannerHelper.shared.error("Failed to send", "Something went wrong while sending the mail", wrapper: view)
            default:
                break
            }
        }
    }
        
}
