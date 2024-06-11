//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

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
