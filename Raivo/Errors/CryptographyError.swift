//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import CommonCrypto

/// Error that describes catastrophic failures during cryptographical calculations.
///
/// - derivation: An error occurred during key derivation
/// - encryption: An error occurred while encrypting data
/// - decryption: An error occurred while decrypting data
public enum CryptographyError: LocalizedError {
    
    case derivationFailed(_ message: String)
    case encryptionFailed(_ message: String)
    case decryptionFailed(_ message: String)
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .derivationFailed(let message):
            log.error("Exception occurred")
            log.error(message)
            return id(self) + " - Derivation error. " + message
        case .encryptionFailed(let message):
            log.error("Exception occurred")
            log.error(message)
            return id(self) + " - Encryption error. " + message
        case .decryptionFailed(let message):
            log.error("Exception occurred")
            log.error(message)
            return id(self) + " - Decryption error. " + message
        }
    }
    
}
