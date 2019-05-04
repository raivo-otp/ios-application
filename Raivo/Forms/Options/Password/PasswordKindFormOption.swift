//
//  PasswordKindFormOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 03/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class PasswordKindFormOption: BaseFormOption {
    
    static let OPTION_TOTP = PasswordKindFormOption("TOTP", description: "Time based (TOTP)")
    static let OPTION_HOTP = PasswordKindFormOption("HOTP", description: "Counter based (HOTP)")
    
    static let OPTION_DEFAULT = OPTION_TOTP
    
    static let options = [
        OPTION_TOTP,
        OPTION_HOTP
    ]
    
    var value: String
    var description: String
    
    init(_ value: String, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: String) -> PasswordKindFormOption? {
        for option in options {
            if option.value.elementsEqual(value) {
                return option
            }
        }
        
        return nil
    }
    
    static func == (lhs: PasswordKindFormOption, rhs: PasswordKindFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}
