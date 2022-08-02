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

import Foundation

class PasswordDigitsFormOption: BaseFormOption {
    
    // https://tools.ietf.org/html/rfc4226#section-5.3 states "Implementations MUST extract a
    // 6-digit code at a minimum and possibly 7 and 8-digit codes."
    static let OPTION_6_DIGITS = PasswordDigitsFormOption(6, description: "6 digits")
    static let OPTION_7_DIGITS = PasswordDigitsFormOption(7, description: "7 digits")
    static let OPTION_8_DIGITS = PasswordDigitsFormOption(8, description: "8 digits")
    
    static let OPTION_DEFAULT = OPTION_6_DIGITS
    
    static let options = [
        OPTION_6_DIGITS,
        OPTION_7_DIGITS,
        OPTION_8_DIGITS
    ]
    
    var value: Int
    var description: String
    
    init(_ value: Int, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: Int) -> PasswordDigitsFormOption? {
        for option in options {
            if option.value == value {
                return option
            }
        }
        
        return nil
    }
    
    static func == (lhs: PasswordDigitsFormOption, rhs: PasswordDigitsFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}

