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

/// Error that describes catastrophic failures that should *NOT* trigger.
///
/// - vitalFunctionalityIsStub: A vital method was executed, but it turned out to be a stub method
/// - noErrorButNotSuccessful: Code did not run successful, but there was no error (this should not trigger)
public enum UnexpectedError: LocalizedError {
    
    case vitalFunctionalityIsStub
    case noErrorButNotSuccessful(_ message: String)
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .vitalFunctionalityIsStub:
            log.error(id(self) + " - VitalFunctionalityIsStub. " + "A vital method was executed, but it turned out to be a stub method")
            return "A vital method was executed, but it turned out to be a stub method"
        case .noErrorButNotSuccessful(let message):
            log.error(id(self) + " - NoErrorButNotSuccessful. " + message)
            return message
        }
    }
    
}
