//
//  MiscForm.swift
//  Raivo
//
//  Created by Tijme Gommers on 07/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Eureka

class MiscForm {
    
    private var form: Form
    
    public let inactivityLockOptions = [
        MiscInactivityLock(20, "20 seconds"),
        MiscInactivityLock(30, "30 seconds"),
        MiscInactivityLock(60, "1 minute"),
        MiscInactivityLock(300, "5 minutes"),
        MiscInactivityLock(600, "10 minutes")
    ]
    
    init(_ form: Form, controller: UIViewController, authenticated: Bool = true) {
        self.form = form
        
        self.form
            
            +++ Section("Synchronization") { section in
                section.tag = "synchronization"
                section.hidden = Condition(booleanLiteral: !authenticated)
            }
            
            <<< LabelRow() { row in
                row.tag = "account"
                row.title = "Account"
                row.value = "Loading..."
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "form-account")
            }
            
            <<< LabelRow() { row in
                row.tag = "provider"
                row.title = "Provider"
                row.value = "Loading..."
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "form-sync")
            }
            
            
            +++ Section("Settings") { section in
                section.hidden = Condition(booleanLiteral: !authenticated)
            }
            
            <<< PickerInlineRow<MiscInactivityLock>() { row in
                row.tag = "inactivity_lock"
                row.title = "Inactivity lock"
                row.options = self.inactivityLockOptions
                row.value = self.inactivityLockOptions[3]
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = ColorHelper.getTint()
                cell.imageView?.image = UIImage(named: "form-lock")
            }.onChange { row in
                KeychainHelper.settings().set(string: String(row.value!.seconds), forKey: KeychainHelper.KEY_LOCKSCREEN_TIMEOUT)
                (MyApplication.shared as! MyApplication).scheduleInactivityTimer()
                row.collapseInlineRow()
            }
            
            <<< ButtonRow() { row in
                row.title = "Change PIN code"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-pincode")
            }.onCellSelection {  cell, row in
                controller.performSegue(withIdentifier: "ChangePincodeSegue", sender: nil)
            }
            
            
            +++ Section("About Raivo")
            
            <<< LabelRow() { row in
                row.title = "Version"
                row.value = AppHelper.version + " (build-" + String(AppHelper.build) + ")"
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "form-version")
            }
            
            <<< LabelRow() { row in
                row.title = "Compilation"
                #if DEBUG
                row.value = "Debug"
                #else
                let testflight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
                row.value = testflight ? "Release (beta)" : "Release"
                #endif
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "form-compilation")
            }
            
            <<< LabelRow() { row in
                row.title = "Author"
                row.value = "@finnwea"
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "form-author")
            }
            
            <<< ButtonRow() { row in
                row.title = "Report a bug"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-bug")
            }.onCellSelection {  cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/issues")!, options: [:])
            }
            
            
            +++ Section("Legal")
            
            <<< ButtonRow() { row in
                row.title = "Privacy policy"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-privacy")
            }.onCellSelection { cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/PRIVACY.md")!, options: [:])
            }
            
            <<< ButtonRow() { row in
                row.title = "Security policy"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-security")
            }.onCellSelection { cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/SECURITY.md")!, options: [:])
            }
            
            <<< ButtonRow() { row in
                row.title = "Raivo license"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-license")
            }.onCellSelection { cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/LICENSE.md")!, options: [:])
            }
            
            
            +++ Section("Advanced") { section in
                section.tag = "advanced"
                section.footer = HeaderFooterView(title: "Signing out will remove all locally stored data from your device. Data that has already been synced will remain at your synchronization provider.")
            }
            
            <<< ButtonRow() { row in
                row.title = "Sign out of Raivo"
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-logout")
            }.onCellSelection { cell, row in
                let refreshAlert = UIAlertController(
                    title: "Are you sure?",
                    message: "Your local Raivo data will be deleted.",
                    preferredStyle: UIAlertController.Style.alert
                )
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
                    StateHelper.reset()
                    (MyApplication.shared.delegate as! AppDelegate).updateStoryboard()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                controller.present(refreshAlert, animated: true, completion: nil)
            }
    }
    
    func isValid() -> Bool {
        form.validate()
        
        for row in form.allRows.filter({ !$0.isHidden}) {
            if !row.isValid {
                row.baseCell.cellBecomeFirstResponder()
                row.select(animated: true, scrollPosition: .top)
                return false
            }
        }
        
        return true
    }
    
}
