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
import OneTimePassword
import Base32

/// A helper class for managing/converting `Password` and `Token` models
class TokenHelper {
    
    /// The singleton instance for the TokenHelper
    public static let shared = TokenHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Convert the given `Password` model to a  `Token` model
    ///
    /// - Parameter password: The password to convert
    /// - Returns: The resulting token
    public func getTokenFromPassword(password: Password) -> Token {
        let factor = getTokenFactorFromPassword(password: password)
        let algorithm = getTokenAlgorithmFromPassword(password: password)

        let generator = Generator(
            factor: factor,
            secret: MF_Base32Codec.data(fromBase32String: password.secret),
            algorithm: algorithm,
            digits: password.digits
        )
        
        return Token(
            name: password.account,
            issuer: password.issuer,
            generator: generator!
        )
    }
    
    /// Convert the given `URL` to a `Token` model
    ///
    /// - Parameter uri: The URL to convert
    /// - Returns: The resulting token
    public func getTokenFromUri(_ uri: URL) -> Token? {
        return Token(url: uri)
    }
    
    /// Get the factor (counter or timer) from the given password
    ///
    /// - Parameter password: The password to convert
    /// - Returns: The resulting factor
    public func getTokenFactorFromPassword(password: Password) -> Generator.Factor {
        switch password.kind {
        case PasswordKindFormOption.OPTION_HOTP.value:
            return Generator.Factor.counter(UInt64(password.counter))
        case PasswordKindFormOption.OPTION_TOTP.value:
            return Generator.Factor.timer(period: Double(password.timer))
        default:
            fatalError("Invalid password kind.")
        }
    }
    
    /// Get the algorithm (sha1, sha256, etc) from the given password
    ///
    /// - Parameter password: The password to use
    /// - Returns: The resulting algorithm
    public func getTokenAlgorithmFromPassword(password: Password) -> Generator.Algorithm {
        switch password.algorithm {
        case PasswordAlgorithmFormOption.OPTION_SHA1.value:
            return Generator.Algorithm.sha1
        case PasswordAlgorithmFormOption.OPTION_SHA256.value:
            return Generator.Algorithm.sha256
        case PasswordAlgorithmFormOption.OPTION_SHA512.value:
            return Generator.Algorithm.sha512
        default:
            fatalError("Invalid password algorithm.")
        }
    }
    
    /// Convert a `Token` to a `Password` model
    ///
    /// - Parameter token: The given token to convert
    /// - Returns: The resulting password
    public func getPasswordFromToken(token: Token) -> Password {
        let password = Password()
         
        password.id = password.getNewPrimaryKey()
        password.issuer = token.issuer.trimmingCharacters(in: .whitespacesAndNewlines)
        password.account = token.name.trimmingCharacters(in: .whitespacesAndNewlines)
        password.secret = MF_Base32Codec.base32String(from: token.generator.secret)
        password.algorithm = getPasswordAlgorithmFromToken(token: token).value
        password.digits = token.generator.digits
        password.kind = getPasswordKindFromToken(token: token).value
        password.syncing = SyncerHelper.shared.getSyncer().recordsRequireSync
        password.synced = !SyncerHelper.shared.getSyncer().recordsRequireSync
        
        switch token.generator.factor {
        case .counter(let counterValue):
            password.counter = Int(counterValue)
        case .timer(let timerInterval):
            password.timer = Int(timerInterval)
        }

        return password
    }
    
    /// Get the algorithm (sha1, sha256, etc) from the given token
    ///
    /// - Parameter token: The token to use
    /// - Returns: The resulting algorithm
    public func getPasswordAlgorithmFromToken(token: Token) -> PasswordAlgorithmFormOption {
        switch token.generator.algorithm {
        case .sha1:
            return PasswordAlgorithmFormOption.OPTION_SHA1
        case .sha256:
            return PasswordAlgorithmFormOption.OPTION_SHA256
        case .sha512:
            return PasswordAlgorithmFormOption.OPTION_SHA512
        }
    }
    
    /// Get the factor/kind (HOTP or TOTP) from the given token
    ///
    /// - Parameter token: The token to use
    /// - Returns: The resulting factor/kind
    public func getPasswordKindFromToken(token: Token) -> PasswordKindFormOption {
        switch token.generator.factor {
        case .counter( _):
            return PasswordKindFormOption.OPTION_HOTP
        case .timer( _):
            return PasswordKindFormOption.OPTION_TOTP
        }
    }
    
    /// Convert the given token to a human-readable string representation
    ///
    /// - Parameter token: The token to use
    /// - Parameter previous: If the previous token should be used
    /// - Returns: A human-readable string representation of the current token
    public func formatPassword(_ token: Token, previous: Bool = false) -> String {
        var password = token.currentPassword!
        
        if previous {
            let lastDate = Calendar.current.date(byAdding: .second, value: -30, to: Date())!
            password = try! token.generator.password(at: lastDate)
        }
        
        switch password.count {
        case 6, 9, 12:
            return splitPassword(password, 3)
        default:
            return splitPassword(password, 4)
        }
    }
    
    /// Add a space between every X (split) characters in the given password
    ///
    /// - Parameter password: The password to use
    /// - Parameter split: Add a space every x'th (`split`) position
    /// - Returns: The formatted string with spaces
    private func splitPassword(_ password: String, _ split: Int) -> String {
        var result = ""
        var counter = 0
        
        for character in password {
            counter += 1
            
            result += String(character)
            
            if (counter % split) == 0 && counter != password.count {
                result += " "
            }
        }
        
        return result
    }
    
}
