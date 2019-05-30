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
import RNCryptor

/// A helper class for running cryptographic calculations
class CryptographyHelper {
    
    /// The singleton instance for the CryptographyHelper
    public static let shared = CryptographyHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Use the PBKDF2 key derivation algorithm to derive the given data to a 64 byte encryption key
    /// https://realm.io/docs/swift/latest/#encryption
    ///
    /// - Parameter secret: The secret to derive
    /// - Parameter salt: The salt to use for derivation
    /// - Returns: A key based on the secret and salt
    /// - Note: Realm only supports 64 byte keys (which is the reason why 64 bytes were chosen)
    public func derive(_ secret: String, withSalt salt: String) -> Data {
        guard let salt = salt.data(using: .utf8) else {
            fatalError("Salt contains non UTF-8 characters")
        }
        
        return derive(secret, withSalt: salt)
    }
    
    /// Use the PBKDF2 key derivation algorithm to derive the given data to a 64 byte encryption key
    /// https://realm.io/docs/swift/latest/#encryption
    ///
    /// - Parameter secret: The secret to derive
    /// - Parameter salt: The salt to use for derivation
    /// - Returns: A key based on the secret and salt
    /// - Note: Realm only supports 64 byte keys (which is the reason why 64 bytes were chosen)
    public func derive(_ secret: String, withSalt salt: Data) -> Data {
        let secretArray = secret.utf8.map(Int8.init)
        let saltArray = Array(salt)
        
        let keySize = 64
        var derivedKey = Array<UInt8>(repeating: 0, count: keySize)
        
        let prf = CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512)
        let pbkdf2Rounds = UInt32(50000)
        
        let result = CCCryptorStatus(
            CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                secretArray,        secretArray.count,
                saltArray,          saltArray.count,
                prf,                pbkdf2Rounds,
                &derivedKey,        keySize
            )
        )
        
        guard result == CCCryptorStatus(kCCSuccess) else {
            fatalError("Key derivation failed. (\(result))")
        }
        
        return Data(derivedKey)
    }
    
    /// Encrypt data using the AES-256 algorithm
    /// https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md
    ///
    /// - Parameter plaintext: The UTF-8 string to encrypt
    /// - Returns: The encrypted string (base64 encoded)
    public func encrypt(_ plaintext: String) -> String {
        guard let plaintextData = plaintext.data(using: .utf8) else {
            fatalError("Plaintext contains non UTF-8 characters")
        }
        
        guard let password = StorageHelper.shared.getEncryptionPassword() else {
            fatalError("Encryption password unknown (not available in the keychain)")
        }
        
        let cipher = RNCryptor.encrypt(
            data: plaintextData,
            withPassword: password
        )
        
        return cipher.base64EncodedString()
    }
    
    /// Decrypt data using the AES-256 algorithm
    /// https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md
    ///
    /// - Parameter cipher: The string to decrypt (base64 encoded)
    /// - Parameter withKey: An optional key to use for decryption (default is key in keychain)
    /// - Returns: The decrypted string
    /// - Throws: Throws error if the password is incorrect or ciphertext is in the wrong format
    public func decrypt(_ cipher: String, withKey key: String? = nil) throws -> String {
        guard let cipherData = Data.init(base64Encoded: cipher) else {
            fatalError("Cipher was not a valid base64 string")
        }
        
        let proposedPassword = key ?? StorageHelper.shared.getEncryptionPassword()
        
        guard let password = proposedPassword else {
            fatalError("Encryption password unknown (not available in the keychain or as parameter)")
        }
        
        let plaintext = try RNCryptor.decrypt(
            data: cipherData,
            withPassword: password
        )
        
        return String(data: plaintext, encoding: .utf8)!
    }

}
