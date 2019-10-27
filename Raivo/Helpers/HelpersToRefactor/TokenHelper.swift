//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import OneTimePassword
import Base32

class TokenHelper {
    
    public static func getTokenFromPassword(password: Password) -> Token {
        let factor = getTokenFactorFromPassword(password: password)
        let algorithm = getTokenAlgorithmFromPassword(password: password)

        let generator = Generator(
            factor: factor,
            secret: MF_Base32Codec.data(fromBase32String: password.secret),
            algorithm: algorithm,
            digits: password.digits
        )

        let originalToken = Token(
            name: password.account,
            issuer: password.issuer,
            generator: generator!
        )

        return originalToken
    }

    public static func getTokenFactorFromPassword(password: Password) -> Generator.Factor {
        switch password.kind {
        case PasswordKindFormOption.OPTION_HOTP.value:
            return Generator.Factor.counter(UInt64(password.counter))
        case PasswordKindFormOption.OPTION_TOTP.value:
            return Generator.Factor.timer(period: Double(password.timer))
        default:
            fatalError("Invalid password kind.")
        }
    }

    public static func getTokenAlgorithmFromPassword(password: Password) -> Generator.Algorithm {
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
    
    public static func getPasswordAlgorithmFromToken(token: Token) -> PasswordAlgorithmFormOption {
        switch token.generator.algorithm {
        case .sha1:
            return PasswordAlgorithmFormOption.OPTION_SHA1
        case .sha256:
            return PasswordAlgorithmFormOption.OPTION_SHA256
        case .sha512:
            return PasswordAlgorithmFormOption.OPTION_SHA512
        }
    }
    
    public static func getPasswordKindFromToken(token: Token) -> PasswordKindFormOption {
        switch token.generator.factor {
        case .counter( _):
            return PasswordKindFormOption.OPTION_HOTP
        case .timer( _):
            return PasswordKindFormOption.OPTION_TOTP
        }
    }
    
    public static func formatPassword(_ token: Token, previous: Bool = false) -> String {
        var password = token.currentPassword!
        
        if previous {
            let lastDate = Calendar.current.date(byAdding: .second, value: -30, to: Date())!
            password = try! token.generator.password(at: lastDate)
        }
        
        switch password.count {
        case 6, 9, 12:
            password = splitPassword(password, 3)
        default:
            password = splitPassword(password, 4)
        }
        
        return password
    }
    
    private static func splitPassword(_ password: String, _ split: Int) -> String {
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
