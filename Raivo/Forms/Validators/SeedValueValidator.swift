//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit
import OneTimePassword

class SeedValueValidator {
    
    static func isValid(_ uri: String) -> Bool {
        guard let uri = URL(string: uri) else {
            return false
        }
        
        return isValid(uri)
    }
    
    static func isValid(_ uri: URL) -> Bool {
        guard Token(url: uri) != nil else {
            return false
        }
        
        return true
    }
    
}
