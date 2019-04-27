//
//  PasswordForm.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Eureka

class PasswordForm {
    
    private var form: Form
    
    init(_ form: Form) {
        self.form = form
        
        self.form
            
            // Syncing errors
            +++ Section("Synchronization status") { section in
                section.tag = "synchronization"
                section.hidden = Condition(booleanLiteral: true)
            }
            <<< LabelRow() { row in
                row.tag = "error"
                row.title = "Unknown"
                row.cell.textLabel?.numberOfLines = 0
            }.cellUpdate { cell, row in
                cell.imageView?.image = UIImage(named: "icon-lightning")
            }
            
            // Product
            +++ Section("Information")
            <<< TextRow() { row in
                row.tag = "issuer"
                row.title = "Title (issuer)"
                row.placeholder = "Twitter"
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }
            <<< TextRow() { row in
                row.tag = "account"
                row.title = "Username"
                row.placeholder = "user@example.ltd"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            // Token
            +++ Section("Token")
            <<< TextRow() { row in
                row.tag = "secret"
                row.title = "Secret/Seed"
                row.placeholder = "2Z7Q7FYWWWDAPW3P"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< PickerInlineRow<String>() { row in
                row.tag = "algorithm"
                row.title = "Algorithm"
                row.options = Password.AlgorithmsArray
                row.value = Password.Algorithms.SHA1
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.onChange { row in
                row.collapseInlineRow()
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }
            <<< IntRow() { row in
                row.tag = "digits"
                row.title = "Length"
                row.placeholder = "Length of token (6 or 8)"
                row.value = 6
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterOrEqualThan(min: 6))
                row.add(rule: RuleSmallerOrEqualThan(max: 8))
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            <<< PickerInlineRow<String>() { row in
                row.tag = "kind"
                row.title = "Type"
                row.options = Password.KindsArray
                row.value = Password.Kinds.TOTP
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.onChange { row in
                row.collapseInlineRow()
                self.evaluateAdvancedSectionsHidden()
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }
        
            // Advanced TOTP
            +++ Section("TOTP") { section in
                section.tag = "totp"
            }
            <<< IntRow() { row in
                row.tag = "timer"
                row.title = "Timer (in seconds)"
                row.placeholder = "30 seconds"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterOrEqualThan(min: 1))
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            // Advanced HOTP
            +++ Section("HOTP") { section in
                section.tag = "hotp"
            }
            <<< IntRow() { row in
                row.tag = "counter"
                row.title = "Counter (initial state)"
                row.placeholder = "0"
                row.cell.textField.autocapitalizationType = UITextAutocapitalizationType.none
                row.cell.textField.autocorrectionType = UITextAutocorrectionType.no
                
                row.validationOptions = .validatesOnDemand
                row.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
        evaluateAdvancedSectionsHidden()
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
    
    func evaluateAdvancedSectionsHidden() {
        let kind = (self.form.rowBy(tag: "kind") as! PickerInlineRow<String>)
        let totp = self.form.sectionBy(tag: "totp")
        let hotp = self.form.sectionBy(tag: "hotp")
        
        totp?.hidden = Condition(booleanLiteral: kind.value != Password.Kinds.TOTP.description)
        hotp?.hidden = Condition(booleanLiteral: kind.value != Password.Kinds.HOTP.description)
        
        totp?.evaluateHidden()
        hotp?.evaluateHidden()
    }
}
