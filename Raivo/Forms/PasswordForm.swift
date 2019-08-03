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
import ViewRow
import EFQRCode

class PasswordForm {
    
    private var form: Form
    
    public var synchronizationSection: Section { return form.sectionBy(tag: "synchronization")! }
    public var genericSection: Section { return form.sectionBy(tag: "generic")! }
    public var tokenSection: Section { return form.sectionBy(tag: "token")! }
    public var totpSection: Section { return form.sectionBy(tag: "totp")! }
    public var hotpSection: Section { return form.sectionBy(tag: "hotp")! }
    
    public var errorRow: LabelRow { return form.rowBy(tag: "error") as! LabelRow }
    public var issuerRow: TextRow { return form.rowBy(tag: "issuer") as! TextRow }
    public var accountRow: TextRow { return form.rowBy(tag: "account") as! TextRow }
    public var iconRow: IconFormRow { return form.rowBy(tag: "icon_url") as! IconFormRow }
    public var secretRow: TextRow { return form.rowBy(tag: "secret") as! TextRow }
    public var algorithmRow: PickerInlineRow<PasswordAlgorithmFormOption> { return form.rowBy(tag: "algorithm") as! PickerInlineRow<PasswordAlgorithmFormOption> }
    public var digitsRow: PickerInlineRow<PasswordDigitsFormOption> { return form.rowBy(tag: "digits") as! PickerInlineRow<PasswordDigitsFormOption> }
    public var kindRow: PickerInlineRow<PasswordKindFormOption> { return form.rowBy(tag: "kind") as! PickerInlineRow<PasswordKindFormOption> }
    public var timerRow: IntRow { return form.rowBy(tag: "timer") as! IntRow }
    public var counterRow: IntRow { return form.rowBy(tag: "counter") as! IntRow }
    
    init(_ form: Form) {
        self.form = form
    }
   
    @discardableResult
    public func build(_ controller: UIViewController) -> Self {
        buildSynchronizationSection()
        buildGenericSection(controller)
        buildTokenSection()
        buildTOTPSection()
        buildHOTPSection()
        
        evaluateSectionVisibility()
        
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
    
    public func evaluateSectionVisibility() {
        totpSection.hidden = Condition(booleanLiteral: kindRow.value != PasswordKindFormOption.OPTION_TOTP)
        hotpSection.hidden = Condition(booleanLiteral: kindRow.value != PasswordKindFormOption.OPTION_HOTP)
        
        totpSection.evaluateHidden()
        hotpSection.evaluateHidden()
    }
    
    private func buildSynchronizationSection() {
        form +++ Section("Synchronization status", { section in
            section.tag = "synchronization"
            section.hidden = Condition(booleanLiteral: true)
        })
            
            <<< LabelRow("error", { row in
                row.title = "Unknown"
                row.cell.textLabel?.numberOfLines = 0
            }).cellUpdate({ cell, row in
                cell.imageView?.image = UIImage(named: "icon-lightning-tint")
            })
    }
    
    private func buildGenericSection(_ controller: UIViewController) {
        form +++ Section("Information", { section in
            section.tag = "generic"
            
            let iconEffectValue = getAppDelegate().getIconEffect()
            if let iconEffect = MiscellaneousIconsEffectFormOption.build(iconEffectValue) {
                section.footer = HeaderFooterView(title: iconEffect.help)
            }
        })
            
            <<< TextRow("issuer", { row in
                row.title = "Title (issuer)"
                row.placeholder = "Twitter"
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            })
            
            <<< TextRow("account", { row in
                row.title = "Username"
                row.placeholder = "user@example.ltd"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            })
        
            <<< IconFormRow(tag: "icon_url", controller: controller, { row in
                row.title = "Icon"
                row.options = PasswordIconTypeFormOption.options
            }).cellUpdate({ cell, row in
                
            })
    }
    
    private func buildTokenSection() {
        form +++ Section("Token", { section in
            section.tag = "token"
        })
            
            <<< TextRow("secret", { row in
                row.title = "Secret/Seed"
                row.placeholder = "2Z7Q7FYWWWDAPW3P"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            })
            
            <<< PickerInlineRow<PasswordAlgorithmFormOption>("algorithm", { row in
                row.title = "Algorithm"
                row.options = PasswordAlgorithmFormOption.options
                row.value = PasswordAlgorithmFormOption.OPTION_DEFAULT
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).onChange({ row in
                row.collapseInlineRow()
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            })
            
            <<< PickerInlineRow<PasswordDigitsFormOption>("digits", { row in
                row.title = "Token length"
                row.options = PasswordDigitsFormOption.options
                row.value = PasswordDigitsFormOption.OPTION_DEFAULT
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).onChange({ row in
                row.collapseInlineRow()
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            })
            
            <<< PickerInlineRow<PasswordKindFormOption>("kind", { row in
                row.title = "Type"
                row.options = PasswordKindFormOption.options
                row.value = PasswordKindFormOption.OPTION_DEFAULT
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).onChange({ row in
                row.collapseInlineRow()
                self.evaluateSectionVisibility()
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            })
    }
    
    private func buildTOTPSection() {
        form +++ Section("TOTP", { section in
            section.tag = "totp"
        })
            
            <<< IntRow("timer", { row in
                row.title = "Timer (in seconds)"
                row.placeholder = "30 seconds"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterOrEqualThan(min: 1))
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            })
    }
    
    private func buildHOTPSection() {
        form +++ Section("HOTP", { section in
            section.tag = "hotp"
        })
            
            <<< IntRow("counter", { row in
                row.title = "Counter (initial state)"
                row.placeholder = "0"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }).cellUpdate({ cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            })
    }
    
}
