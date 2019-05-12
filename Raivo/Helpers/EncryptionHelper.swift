//
//  EncryptionHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RNCryptor

class EncryptionHelper {
    
    public static func encrypt(_ plaintextMessage: String) throws -> String {
        let messageData = plaintextMessage.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: StorageHelper.getEncryptionPassword()!)
        
        return cipherData.base64EncodedString()
    }
    
    public static func decrypt(_ encryptedMessage: String, withKey: String? = nil) throws -> String {
        var salt:String? = nil
        
        if withKey != nil {
            salt = withKey!
        } else {
            salt = StorageHelper.getEncryptionPassword()
        }
        
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: salt!)
        
        return String(data: decryptedData, encoding: .utf8)!
    }
    
}
