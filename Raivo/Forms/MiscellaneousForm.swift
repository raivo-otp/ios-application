//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import Eureka

class MiscellaneousForm {
    
    private var form: Form
    
    private var isReady = false
    
    public var synchronizationSection: Section { return form.sectionBy(tag: "synchronization")! }
    public var authenticationSection: Section { return form.sectionBy(tag: "authentication")! }
    public var interfaceSection: Section { return form.sectionBy(tag: "interface")! }
    public var aboutSection: Section { return form.sectionBy(tag: "about")! }
    public var legalSection: Section { return form.sectionBy(tag: "legal")! }
    public var advancedSection: Section { return form.sectionBy(tag: "advanced")! }
    
    public var accountRow: LabelRow { return form.rowBy(tag: "account") as! LabelRow }
    public var providerRow: LabelRow { return form.rowBy(tag: "provider") as! LabelRow }
    public var inactivityLockRow: PickerInlineRow<MiscellaneousInactivityLockFormOption> { return form.rowBy(tag: "inactivity_lock") as! PickerInlineRow<MiscellaneousInactivityLockFormOption> }
    public var touchIDUnlockRow: SwitchRow { return form.rowBy(tag: "touchid_unlock") as! SwitchRow }
    public var changePINCodeRow: ButtonRow { return form.rowBy(tag: "change_pin_code") as! ButtonRow }
    public var iconsEffectRow: PickerInlineRow<MiscellaneousIconsEffectFormOption> { return form.rowBy(tag: "icons_effect") as! PickerInlineRow<MiscellaneousIconsEffectFormOption> }
    public var versionRow: LabelRow { return form.rowBy(tag: "version") as! LabelRow }
    public var compilationRow: LabelRow { return form.rowBy(tag: "compilation") as! LabelRow }
    public var authorRow: LabelRow { return form.rowBy(tag: "author") as! LabelRow }
    public var reportBugRow: ButtonRow { return form.rowBy(tag: "report_a_bug") as! ButtonRow }
    public var privacyPolicyRow: ButtonRow { return form.rowBy(tag: "privacy_policy") as! ButtonRow }
    public var securityPolicyRow: ButtonRow { return form.rowBy(tag: "security_policy") as! ButtonRow }
    public var licenseRow: ButtonRow { return form.rowBy(tag: "license") as! ButtonRow }
    public var signOutRow: ButtonRow { return form.rowBy(tag: "sign_out") as! ButtonRow }
    
    init(_ form: Form) {
        self.form = form
    }
    
    @discardableResult
    public func build(controller: UIViewController) -> Self {
        buildSynchronizationSection(controller)
        buildAuthenticationSection(controller)
        buildInterfaceSection(controller)
        buildAboutSection(controller)
        buildLegalSection(controller)
        buildAdvancedSection(controller)
        
        return self
    }
    
    @discardableResult
    public func ready() -> Self {
        self.isReady = true
        return self
    }
    
    public func inputIsValid() -> Bool {
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
    
    private func buildSynchronizationSection(_ controller: UIViewController) {
        let authenticated = StateHelper.shared.getCurrentStoryboard() == StateHelper.Storyboard.MAIN
        
        form +++ Section("Synchronization", { section in
            section.tag = "synchronization"
            section.hidden = Condition(booleanLiteral: !authenticated)
            section.footer = HeaderFooterView(title: SyncerHelper.shared.getSyncer().help)
       })
            
            <<< LabelRow("account", { row in
                row.title = "Account"
                row.value = "Loading..."
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-account")
            })
            
            <<< LabelRow("provider", { row in
                row.title = "Provider"
                row.value = "Loading..."
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-sync")
            })
    }
    
    private func buildAuthenticationSection(_ controller: UIViewController) {
        let authenticated = StateHelper.shared.getCurrentStoryboard() == StateHelper.Storyboard.MAIN
        
        form +++ Section("Authentication", { section in
            section.tag = "authentication"
            section.hidden = Condition(booleanLiteral: !authenticated)
        })
            
            <<< PickerInlineRow<MiscellaneousInactivityLockFormOption>("inactivity_lock", { row in
                row.title = "Inactivity lock"
                row.options = MiscellaneousInactivityLockFormOption.options
                row.value = MiscellaneousInactivityLockFormOption.OPTION_DEFAULT
            }).cellUpdate({ cell, row in
                cell.textLabel?.textColor = ColorHelper.getTint()
                cell.imageView?.image = UIImage(named: "form-lock")
            }).onChange({ row in
                StorageHelper.shared.setLockscreenTimeout(row.value!.value)
                getAppPrincipal().scheduleInactivityTimer()
                row.collapseInlineRow()
            })
            
            <<< SwitchRow("touchid_unlock", { row in
                row.title = "TouchID unlock"
                row.hidden = Condition(booleanLiteral: !StorageHelper.shared.canAccessSecrets())
                row.value = StorageHelper.shared.getBiometricUnlockEnabled()
            }).cellUpdate({ cell, row in
                cell.textLabel?.textColor = ColorHelper.getTint()
                cell.imageView?.image = UIImage(named: "form-biometric")
                cell.switchControl.tintColor = ColorHelper.getTint()
                cell.switchControl.onTintColor = ColorHelper.getTint()
            }).onChange({ row in
                guard let key = getAppDelegate().getEncryptionKey() else {
                    return
                }
                
                // Bugfix for invalid SwitchRow background if TouchID was cancelled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if !(row.value ?? false) {
                        StorageHelper.shared.setEncryptionKey(nil)
                        StorageHelper.shared.setBiometricUnlockEnabled(false)
                    } else {
                        StorageHelper.shared.setEncryptionKey(key.base64EncodedString())
                        
                        if StorageHelper.shared.getEncryptionKey(prompt: "Confirm to enable TouchID") != nil {
                            StorageHelper.shared.setBiometricUnlockEnabled(true)
                        } else {
                            row.value = false
                            row.cell.switchControl.setOn(false, animated: true)
                        }
                    }
                }
            })
            
            <<< ButtonRow("change_pin_code", { row in
                row.title = "Change PIN code"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-pincode")
            }).onCellSelection({ cell, row in
                controller.performSegue(withIdentifier: "ChangePincodeSegue", sender: nil)
            })
    }
    
    private func buildInterfaceSection(_ controller: UIViewController) {
        let authenticated = StateHelper.shared.getCurrentStoryboard() == StateHelper.Storyboard.MAIN
        
        form +++ Section("Interface", { section in
            section.tag = "interface"
            section.hidden = Condition(booleanLiteral: !authenticated)
        })
            
            <<< PickerInlineRow<MiscellaneousIconsEffectFormOption>("icons_effect", { row in
                row.title = "Icons effect"
                row.options = MiscellaneousIconsEffectFormOption.options
                row.value = MiscellaneousIconsEffectFormOption.OPTION_DEFAULT
            }).cellUpdate({ cell, row in
                cell.textLabel?.textColor = ColorHelper.getTint()
                cell.imageView?.image = UIImage(named: "form-icons-effect")
            }).onChange({ row in
                guard self.isReady else { return }
                
                StorageHelper.shared.setIconsEffect(row.value!.value)
                row.collapseInlineRow()
                
                let refreshAlert = UIAlertController(
                    title: "Restart required!",
                    message: "The effect of the icons will change after you've restarted Raivo.",
                    preferredStyle: UIAlertController.Style.alert
                )
                
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                controller.present(refreshAlert, animated: true, completion: nil)
            })
    }
    
    private func buildAboutSection(_ controller: UIViewController) {
        form +++ Section("About Raivo", { section in
            section.tag = "about"
        })
    
            <<< LabelRow("version", { row in
                row.title = "Version"
                row.value = AppHelper.version + " (build-" + String(AppHelper.build) + ")"
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-version")
            })
            
            <<< LabelRow("compilation", { row in
                row.title = "Compilation"
                row.value = AppHelper.compilation
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-compilation")
            })
            
            <<< LabelRow("author", { row in
                row.title = "Author"
                row.value = "@finnwea"
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-author")
            })
            
            <<< ButtonRow("report_a_bug", { row in
                row.title = "Report a bug"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-bug")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/issues")!, options: [:])
            })
    }
    
    private func buildLegalSection(_ controller: UIViewController) {
        form +++ Section("Legal", { section in
            section.tag = "legal"
        })
    
            <<< ButtonRow("privacy_policy", { row in
                row.title = "Privacy policy"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-privacy")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/PRIVACY.md")!, options: [:])
            })
            
            <<< ButtonRow("security_policy", { row in
                row.title = "Security policy"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-security")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/SECURITY.md")!, options: [:])
            })
            
            <<< ButtonRow("license", { row in
                row.title = "Raivo license"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-license")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/tijme/raivo/blob/master/LICENSE.md")!, options: [:])
            })
    }
    
    private func buildAdvancedSection(_ controller: UIViewController) {
        let show = [StateHelper.Storyboard.MAIN, StateHelper.Storyboard.AUTH].contains(StateHelper.shared.getCurrentStoryboard())
        
        form +++ Section("Advanced", { section in
            section.tag = "advanced"
            section.hidden = Condition(booleanLiteral: !show)
            
            let footerTitle = "Signing out will remove all data from your device."
            if [id(MockSyncer.self), id(OfflineSyncer.self)].contains(id(SyncerHelper.shared.getSyncer().self)) {
                section.footer = HeaderFooterView(title: footerTitle)
            } else {
                section.footer = HeaderFooterView(title: footerTitle + " Data that has already been synced will remain at your synchronization provider.")
            }
        })
            
            <<< ButtonRow("sign_out", { row in
                row.title = "Sign out of Raivo"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-logout")
            }).onCellSelection({ cell, row in
                let refreshAlert = UIAlertController(
                    title: "Are you sure?",
                    message: "Your local Raivo data will be deleted.",
                    preferredStyle: UIAlertController.Style.alert
                )
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
                    StateHelper.shared.reset()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                controller.present(refreshAlert, animated: true, completion: nil)
            })
    }
    
}
