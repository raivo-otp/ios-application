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
            log.error(id(self) + " - Derivation error. " + message)
            return message
        case .encryptionFailed(let message):
            log.error(id(self) + " - Encryption error. " + message)
            return message
        case .decryptionFailed(let message):
            log.error(id(self) + " - Decryption error. " + message)
            return message
        }
    }
    
}
