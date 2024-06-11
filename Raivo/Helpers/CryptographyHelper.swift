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
import RNCryptor

/// A helper class for performing cryptographic calculations.
class CryptographyHelper {
    
    /// The singleton instance for the CryptographyHelper
    public static let shared = CryptographyHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Use the PBKDF2 key derivation algorithm to derive the given data to a 64 byte encryption key
    ///
    /// - Parameter secret: The secret to derive (for end-users, this is called the passcode)
    /// - Parameter salt: The salt to use for derivation (for end-users, this is called the password)
    /// - Returns: A key based on the secret and salt
    /// - Note Realm only supports 64 byte keys (which is the reason why 64 bytes were chosen)
    /// - Note Specifications:
    ///         https://realm.io/docs/swift/latest/#encryption
    public func derive(_ secret: String, withSalt salt: String) throws -> Data {
        guard let salt = salt.data(using: .utf8) else {
            throw CryptographyError.derivationFailed("Password contains non UTF-8 characters")
        }
        
        return try derive(secret, withSalt: salt)
    }
    
    /// Use the PBKDF2 key derivation algorithm to derive the given data to a 64 byte encryption key
    ///
    /// - Parameter secret: The secret to derive
    /// - Parameter salt: The salt to use for derivation
    /// - Returns: A key based on the secret and salt
    /// - Note Realm only supports 64 byte keys (which is the reason why 64 bytes were chosen)
    /// - Note Specifications:
    ///         https://realm.io/docs/swift/latest/#encryption
    public func derive(_ secret: String, withSalt salt: Data) throws -> Data {
        let secretArray = secret.utf8.map(Int8.init)
        let saltArray = Array(salt)
        
        let keySize = 64
        var derivedKey = Array<UInt8>(repeating: 0, count: keySize)
        
        let prf = CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512)
        let pbkdf2Rounds = UInt32(50000)
        
        let status = CCCryptorStatus(
            CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                secretArray,        secretArray.count,
                saltArray,          saltArray.count,
                prf,                pbkdf2Rounds,
                &derivedKey,        keySize
            )
        )
        
        guard status == CCCryptorStatus(kCCSuccess) else {
            throw CryptographyError.derivationFailed("Key derivation failed: (\(status))")
        }
        
        return Data(derivedKey)
    }
    
    /// Encrypt data using the AES-256 algorithm
    ///
    /// - Parameter plaintext: The UTF-8 string to encrypt
    /// - Parameter withKey: An optional key to use for encryption (default is key in keychain)
    /// - Returns: The encrypted string (base64 encoded)
    /// - Note Specifications:
    ///         https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md
    public func encrypt(_ plaintext: String, withKey key: String? = nil) throws -> String {
        guard let plaintextData = plaintext.data(using: .utf8) else {
            throw CryptographyError.encryptionFailed("Plaintext contains non UTF-8 characters")
        }
        
        let proposedPassword = key ?? StorageHelper.shared.getEncryptionPassword()
        
        guard let password = proposedPassword else {
            throw CryptographyError.encryptionFailed("Encryption password unknown (not available in the keychain)")
        }
        
        let cipher = RNCryptor.encrypt(
            data: plaintextData,
            withPassword: password
        )
        
        return cipher.base64EncodedString()
    }
    
    /// Decrypt data using the AES-256 algorithm
    ///
    /// - Parameter cipher: The string to decrypt (base64 encoded)
    /// - Parameter withKey: An optional key to use for decryption (default is key in keychain)
    /// - Returns: The decrypted string
    /// - Throws: Throws error if the password is incorrect or ciphertext is in the wrong format
    /// - Note Specifications:
    ///         https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md
    public func decrypt(_ cipher: String, withKey key: String? = nil) throws -> String {
        guard let cipherData = Data.init(base64Encoded: cipher) else {
            throw CryptographyError.decryptionFailed("Cipher was not a valid base64 string")
        }
        
        let proposedPassword = key ?? StorageHelper.shared.getEncryptionPassword()
        
        guard let password = proposedPassword else {
            throw CryptographyError.decryptionFailed("Encryption password unknown (not available in the keychain or as parameter)")
        }
        
        let plaintext = try RNCryptor.decrypt(
            data: cipherData,
            withPassword: password
        )
        
        return String(data: plaintext, encoding: .utf8)!
    }
    
    /// Check if given passcode is very weak
    ///
    /// - Parameter passcode: The passcode to check the weakness for
    /// - Returns: Positive if very weak
    public func passcodeIsVeryWeak(_ passcode: String) -> Bool {
        // Remove duplicate characters and check string length
        var set = Set<Character>()
        let squeezed = passcode.filter{ set.insert($0).inserted }
        if (squeezed.count <= 2) {
            return true
        }
        
        if "0123456789".contains(passcode) {
            return true
        }
        
        if "9876543210".contains(passcode) {
            return true
        }
        
        return false
    }
    
    /// Check if given password is very weak
    ///
    /// - Parameter passcode: The password to check the weakness for
    /// - Returns: Positive if very weak
    public func passwordIsVeryWeak(_ password: String) -> Bool {
        // Remove duplicate characters and check string length
        var set = Set<Character>()
        let squeezed = password.filter{ set.insert($0).inserted }
        if (squeezed.count <= 3) {
            return true
        }
        
        var strength: Int = 0
        
        switch password.count {
        case 0...7:
            return true
        case 8...12:
            strength += 2
        default:
            strength += 3
        }
        
        let patterns = [
            try! NSRegularExpression(pattern: "[A-Z]"),
            try! NSRegularExpression(pattern:"[a-z]"),
            try! NSRegularExpression(pattern:"[0-9]"),
            try! NSRegularExpression(pattern:"[^A-Za-z0-9]")
        ]
        
        let range = NSRange(location: 0, length: password.utf16.count)

        for pattern in patterns {
            if (pattern.firstMatch(in: password, options: [], range: range) != nil) {
                strength += 1
            }
        }
        
        return strength < 5
    }

}
