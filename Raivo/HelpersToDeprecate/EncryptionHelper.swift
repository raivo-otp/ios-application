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
import RNCryptor

class EncryptionHelper {
    
    public static func encrypt(_ plaintextMessage: String) throws -> String {
        let messageData = plaintextMessage.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: StorageHelper.shared.getEncryptionPassword()!)
        
        return cipherData.base64EncodedString()
    }
    
    public static func decrypt(_ encryptedMessage: String, withKey: String? = nil) throws -> String {
        var salt:String? = nil
        
        if withKey != nil {
            salt = withKey!
        } else {
            salt = StorageHelper.shared.getEncryptionPassword()
        }
        
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: salt!)
        
        return String(data: decryptedData, encoding: .utf8)!
    }
    
}
