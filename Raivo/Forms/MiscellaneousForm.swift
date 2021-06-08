//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import Eureka
import MessageUI

class MiscellaneousForm {
    
    private var form: Form
    
    private var isReady = false
    
    public var synchronizationSection: Section { return form.sectionBy(tag: "synchronization")! }
    public var authenticationSection: Section { return form.sectionBy(tag: "authentication")! }
    public var interfaceSection: Section { return form.sectionBy(tag: "interface")! }
    public var dataSection: Section { return form.sectionBy(tag: "data")! }
    public var loggingSection: Section { return form.sectionBy(tag: "logging")! }
    public var aboutSection: Section { return form.sectionBy(tag: "about")! }
    public var legalSection: Section { return form.sectionBy(tag: "legal")! }
    public var advancedSection: Section { return form.sectionBy(tag: "advanced")! }
    
    public var accountRow: LabelRow { return form.rowBy(tag: "account") as! LabelRow }
    public var providerRow: LabelRow { return form.rowBy(tag: "provider") as! LabelRow }
    public var statusRow: LabelRow { return form.rowBy(tag: "status") as! LabelRow }
    public var inactivityLockRow: PickerInlineRow<MiscellaneousInactivityLockFormOption> { return form.rowBy(tag: "inactivity_lock") as! PickerInlineRow<MiscellaneousInactivityLockFormOption> }
    public var biometricUnlockRow: SwitchRow { return form.rowBy(tag: "biometric_unlock") as! SwitchRow }
    public var changePasscodeRow: ButtonRow { return form.rowBy(tag: "change_passcode") as! ButtonRow }
    public var iconsEffectRow: PickerInlineRow<MiscellaneousIconsEffectFormOption> { return form.rowBy(tag: "icons_effect") as! PickerInlineRow<MiscellaneousIconsEffectFormOption> }
    public var exportRow: ButtonRow { return form.rowBy(tag: "export") as! ButtonRow }
    public var loggingEnabledRow: SwitchRow { return form.rowBy(tag: "logging_enabled") as! SwitchRow }
    public var loggingShareRow: ButtonRow { return form.rowBy(tag: "logging_share") as! ButtonRow }
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
    
    public func build<T: UIViewController & MFMailComposeViewControllerDelegate>(controller: T) -> Self {
        buildSynchronizationSection(controller)
        buildAuthenticationSection(controller)
        buildInterfaceSection(controller)
        buildDataSection(controller)
        buildLoggingSection(controller)
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
            cell.imageView?.image = UIImage(named: "form-provider")
        })
        
        <<< LabelRow("status", { row in
            row.title = "Status"
            row.value = "Loading..."
        }).cellUpdate({ cell, row in
            cell.imageView?.image = UIImage(named: "form-status")
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
                cell.textLabel?.textColor = UIColor.getTintRed()
                cell.imageView?.image = UIImage(named: "form-lock")
            }).onChange({ row in
                StorageHelper.shared.setLockscreenTimeout(row.value!.value)
                getAppPrincipal().scheduleInactivityTimer()
                row.collapseInlineRow()
            })
            
            <<< SwitchRow("biometric_unlock", { row in
                row.title = (BiometricHelper.shared.type() == .face ? "FaceID" : "TouchID") + " unlock"
                row.hidden = Condition(booleanLiteral: !StorageHelper.shared.canAccessSecrets())
                row.value = StorageHelper.shared.getBiometricUnlockEnabled()
            }).cellUpdate({ cell, row in
                cell.textLabel?.textColor = UIColor.getTintRed()
                cell.imageView?.image = UIImage(named: "form-biometric-" + (BiometricHelper.shared.type() == .face ? "faceid" : "touchid"))
                cell.switchControl.tintColor = UIColor.getTintRed()
                cell.switchControl.onTintColor = UIColor.getTintRed()
            }).onChange({ row in
                guard let key = getAppDelegate().getEncryptionKey() else {
                    return
                }
                
                if !(row.value ?? false) {
                    StorageHelper.shared.setEncryptionKey(nil)
                    StorageHelper.shared.setBiometricUnlockEnabled(false)
                } else {
                    StorageHelper.shared.setEncryptionKey(key.base64EncodedString())
                    StorageHelper.shared.setBiometricUnlockEnabled(true)
                }
            })
            
            <<< ButtonRow("change_passcode", { row in
                row.title = "Change passcode"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-passcode")
            }).onCellSelection({ cell, row in
                controller.performSegue(withIdentifier: "MainChangePasscodeSegue", sender: nil)
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
                cell.textLabel?.textColor = UIColor.getTintRed()
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
    
    private func buildDataSection<T: UIViewController & MFMailComposeViewControllerDelegate>(_ controller: T) {
        let authenticated = StateHelper.shared.getCurrentStoryboard() == StateHelper.Storyboard.MAIN
        
        form +++ Section("Data", { section in
            section.tag = "data"
            section.hidden = Condition(booleanLiteral: !authenticated)
            section.footer = HeaderFooterView(title: "Your data will be exported in an AES encrypted ZIP archive (using your encryption password).")
        })
            
            <<< ButtonRow("export", { row in
                row.title = "Export OTPs to ZIP archive"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-zip")
            }).onCellSelection({ cell, row in
                controller.performSegue(withIdentifier: "MainDataExportSegue", sender: self)
            })
    }
    
    private func buildLoggingSection(_ controller: UIViewController) {
        let authenticated = StateHelper.shared.getCurrentStoryboard() == StateHelper.Storyboard.MAIN
        
        form +++ Section("Debug logging", { section in
            section.tag = "logging"
            section.hidden = Condition(booleanLiteral: !authenticated)
            section.footer = HeaderFooterView(title: "Log files are stored locally and contain metadata only. Please note that they're persistent, even if you sign out.")
        })
            
            <<< SwitchRow("logging_enabled", { row in
                row.title = "Log to local file"
                row.value = StorageHelper.shared.getFileLoggingEnabled()
            }).cellUpdate({ cell, row in
                cell.textLabel?.textColor = UIColor.getTintRed()
                cell.imageView?.image = UIImage(named: "form-logging-enabled")
                cell.switchControl.tintColor = UIColor.getTintRed()
                cell.switchControl.onTintColor = UIColor.getTintRed()
            }).onChange({ row in
                StorageHelper.shared.setFileLoggingEnabled(row.value ?? false)
                
                if StorageHelper.shared.getFileLoggingEnabled() {
                    initializeFileLogging()
                } else {
                    log.removeDestination(logFileDestination)
                }
            })
            
            <<< ButtonRow("logging_share", { row in
                row.title = "Export log to TXT file"
                row.hidden = Condition.function(["logging_enabled"], { form in
                    return !(self.loggingEnabledRow.value ?? false)
                })
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-logging-share")
            }).onCellSelection({ cell, row in
                if let logFile = logFileDestination.logFileURL {
                    let activity = UIActivityViewController(activityItems: [logFile], applicationActivities: nil)
                    controller.present(activity, animated: true, completion: nil)
                } else {
                    let refreshAlert = UIAlertController(
                        title: "Log unavailable!",
                        message: "The local log file could not be found.",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    
                    refreshAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    controller.present(refreshAlert, animated: true, completion: nil)
                }
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
                row.value = "Tijme Gommers"
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "form-author")
            })
            
            <<< ButtonRow("report_a_bug", { row in
                row.title = "Report a bug"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-bug")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/raivo-otp/ios-application/issues/new/choose")!, options: [:])
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
                UIApplication.shared.open(URL(string: "https://github.com/raivo-otp/ios-application/blob/master/PRIVACY.md#privacy-policy")!, options: [:])
            })
            
            <<< ButtonRow("security_policy", { row in
                row.title = "Security policy"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-security")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/raivo-otp/ios-application/blob/master/SECURITY.md#security-policy")!, options: [:])
            })
            
            <<< ButtonRow("license", { row in
                row.title = "Raivo license"
            }).cellUpdate({ cell, row in
                cell.textLabel?.textAlignment = .left
                cell.imageView?.image = UIImage(named: "form-license")
            }).onCellSelection({ cell, row in
                UIApplication.shared.open(URL(string: "https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md#attribution-noncommercial-40-international")!, options: [:])
            })
    }
    
    private func buildAdvancedSection(_ controller: UIViewController) {
        let show = [StateHelper.Storyboard.MAIN, StateHelper.Storyboard.AUTH].contains(StateHelper.shared.getCurrentStoryboard())
        
        form +++ Section("Advanced", { section in
            section.tag = "advanced"
            section.hidden = Condition(booleanLiteral: !show)
            
            let footerTitle = "Signing out will remove all data from your device."
            if [id(StubSyncer.self), id(OfflineSyncer.self)].contains(id(SyncerHelper.shared.getSyncer().self)) {
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
                    log.warning("Signing out of the application")
                    StateHelper.shared.reset()
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                controller.present(refreshAlert, animated: true, completion: nil)
            })
    }
    
}
