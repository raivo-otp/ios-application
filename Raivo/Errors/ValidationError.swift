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
