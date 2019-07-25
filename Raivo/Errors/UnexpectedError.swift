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

/// Error that describes catastrophic failures that should *NOT* trigger.
///
/// - vitalFunctionalityIsStub: A vital method was executed, but it turned out to be a stub method
/// - noErrorButNotSuccessful: Code did not run successful, but there was no error (this should not trigger)
public enum UnexpectedError: LocalizedError {
    
    case vitalFunctionalityIsStub
    case noErrorButNotSuccessful(_ message: String)
    
    public var errorDescription: String? {
        switch self {
        case .vitalFunctionalityIsStub:
            return "A vital method was executed, but it turned out to be a stub method"
        case .noErrorButNotSuccessful(let message):
            return message
        }
    }
    
}
