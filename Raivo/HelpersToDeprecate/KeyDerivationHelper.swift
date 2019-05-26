//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import CommonCrypto
import Foundation

class KeyDerivationHelper {
    
    public static func derivePincode(_ pincode: String, _ salt: String) -> Data? {
        return pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), password: pincode, salt: salt.data(using: .utf8)!, keyByteCount: 64, rounds: 50000)
    }
    
    private static func pbkdf2(hash: CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        let passwordData = password.data(using: String.Encoding.utf8)!
        var derivedKeyData = Data(repeating: 0, count:keyByteCount)
        let derivedKeyDataCount = derivedKeyData.count
        
        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    passwordData.count,
                    saltBytes,
                    salt.count,
                    hash,
                    UInt32(rounds),
                    derivedKeyBytes,
                    derivedKeyDataCount
                )
            }
        }
        
        if (derivationStatus != 0) {
            log.error("Error: \(derivationStatus)")
            return nil;
        }
        
        return derivedKeyData
    }
    
}
