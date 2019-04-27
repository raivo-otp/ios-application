//
//  TokenHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
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
        if password.kind == Password.Kinds.HOTP {
            return Generator.Factor.counter(UInt64(password.counter))
        } else {
            return Generator.Factor.timer(period: Double(password.timer))
        }
    }

    public static func getTokenAlgorithmFromPassword(password: Password) -> Generator.Algorithm {
        if password.algorithm == Password.Algorithms.SHA256 {
            return Generator.Algorithm.sha512
        } else if password.algorithm == Password.Algorithms.SHA256 {
            return Generator.Algorithm.sha256
        } else {
            return Generator.Algorithm.sha1
        }
    }
    
    public static func getPasswordAlgorithmFromToken(token: Token) -> String {
        switch token.generator.algorithm {
        case .sha1:
            return Password.Algorithms.SHA1
        case .sha256:
            return Password.Algorithms.SHA256
        case .sha512:
            return Password.Algorithms.SHA512
        }
    }
    
    public static func getPasswordKindFromToken(token: Token) -> String {
        switch token.generator.factor {
        case .counter( _):
                return Password.Kinds.HOTP
        case .timer( _):
                return Password.Kinds.TOTP
        }
    }
    
    public static func formatPassword(_ token: Token, previous: Bool = false) -> String {
        var password = token.currentPassword!
        
        if previous {
            let lastDate = Calendar.current.date(byAdding: .second, value: -30, to: Date())!
            password = try! token.generator.password(at: lastDate)
        }
        
        switch password.length {
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
            
            if (counter % split) == 0 && counter != password.length {
                result += " "
            }
        }
        
        return result
    }
    
}
