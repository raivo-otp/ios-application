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
    
    public var errorDescription: String? {
        switch self {
        case .derivationFailed(let message):
            return id(self) + " - Derivation error. " + message
        case .encryptionFailed(let message):
            return id(self) + " - Encryption error. " + message
        case .decryptionFailed(let message):
            return id(self) + " - Decryption error. " + message
        }
    }
    
}
