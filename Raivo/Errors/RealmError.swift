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

/// Error that describes Realm Objective-C exceptions that can be converted to Swift
///
/// - unknownError: An unknown Realm error occurred and we can't recover from it
/// - encryptionError: The encryption or decryption of the Realm failed
public enum RealmError: LocalizedError {
    
    case unknownError
    case encryptionError
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            log.error(id(self) + " - Unknown Error. " + "An unknown Realm Objective-C exception occurred")
            return "An unknown Realm Objective-C exception occurred"
        case .encryptionError:
            log.error(id(self) + " - Encryption Error. " + "A Realm Objective-C invalid encryption key exception occurred")
            return "A Realm Objective-C invalid encryption key exception occurred"
        }
    }
    
}
