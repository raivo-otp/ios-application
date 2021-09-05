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

/// Error that describes data validation exceptions
///
/// - invalidFormat: The given data had an invalid format
public enum ValidationError: LocalizedError {
    
    case invalidFormat(_ message: String)
 
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .invalidFormat(let message):
            log.error(id(self) + " - Invalid format. " + message)
            return message
        }
    }
    
}
