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

/// Error that describes Realm Objective-C exceptions that can be converted to Swift
///
/// - vitalFunctionalityIsStub: A vital method was executed, but it turned out to be a stub method
/// - noErrorButNotSuccessful: Code did not run successful, but there was no error (this should not trigger)
public enum RealmError: LocalizedError {
    
    case unknownError
    case encryptionError
    
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            log.error("Exception occurred")
            return "An unknown Realm Objective-C exception occurred"
        case .encryptionError:
            log.error("Encryption error occurred")
            return "A Realm Objective-C invalid encryption key exception occurred"
        }
    }
    
}
