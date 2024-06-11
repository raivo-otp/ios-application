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
import CloudKit
import RealmSwift

class CloudKitPasswordConverter: CloudKitModelConverterProtocol {
    
    static func getLocal(_ record: CKRecord) throws -> Password? {
        return try autoreleasepool { () throws -> Password? in
            guard let realm = try? RealmHelper.shared.getRealm(feedbackOnError: false) else {
                log.error("Trying to get local CloudKit password but realm is nil")
                throw RealmError.encryptionError
            }
            
            let id = record.value(forKey: "id") as! Int64
            return realm.object(ofType: Password.self, forPrimaryKey: id)
        }
    }
    
    static func getLocalCopy(_ record: CKRecord, syncedCorrectly: Bool = false) throws -> Password {
        // We use a mock so we can fill it without write transactions
        let password = Password()
        
        password.id = record.value(forKey: "id") as! Int64
        password.kind = record.value(forKey: "kind") as! String
        password.iconType = record.value(forKey: "iconType") as? String ?? ""
        password.iconValue = record.value(forKey: "iconValue") as? String ?? ""
        password.algorithm = record.value(forKey: "algorithm") as! String
        password.digits = record.value(forKey: "digits") as! Int
        password.counter = record.value(forKey: "counter") as! Int
        password.timer = record.value(forKey: "timer") as! Int
        password.pinned = (record.value(forKey: "pinned") as? Int ?? 0) == 1
        password.deleted = (record.value(forKey: "deleted") as! Int) == 1
                
        do {
            password.issuer = try CryptographyHelper.shared.decrypt(record.value(forKey: "issuer") as! String)
            password.account = try CryptographyHelper.shared.decrypt(record.value(forKey: "account") as! String)
            password.secret = try CryptographyHelper.shared.decrypt(record.value(forKey: "secret") as! String)
        } catch let error {
            log.error(error.localizedDescription)
        }
        
        // We use some of the original values that are not stored in the CKRecord
        // But only if the local record exists
        if let original = try getLocal(record) {
            password.synced = original.synced
            password.syncing = original.syncing
            password.syncErrorDescription = original.syncErrorDescription
            password.syncErrorType = original.syncErrorType
        }
        
        // If 'syncedCorrectly', pretend like the password was synced correctly
        // Usefull if receiving it from CloudKit
        if syncedCorrectly {
            password.synced = true
            password.syncing = false
            password.syncErrorType = nil
            password.syncErrorDescription = nil
        }
        
        return password
    }
    
    static func getRemote(_ password: Password) -> CKRecord {
        let record = CKRecord(recordType: Password.TABLE, recordID: CKRecord.ID(recordName: password.getRemotePrimaryKey()))
        
        record.setValue(password.id, forKey: "id")
        record.setValue(password.kind, forKey: "kind")
        record.setValue(try! CryptographyHelper.shared.encrypt(password.issuer), forKey: "issuer")
        record.setValue(try! CryptographyHelper.shared.encrypt(password.account), forKey: "account")
        record.setValue(try! CryptographyHelper.shared.encrypt(password.secret), forKey: "secret")
        record.setValue(password.iconType, forKey: "iconType")
        record.setValue(password.iconValue, forKey: "iconValue")
        record.setValue(password.algorithm, forKey: "algorithm")
        record.setValue(password.digits, forKey: "digits")
        record.setValue(password.pinned, forKey: "pinned")
        record.setValue(password.deleted, forKey: "deleted")
        record.setValue(password.counter, forKey: "counter")
        record.setValue(password.timer, forKey: "timer")
    
        return record
    }
    
    
}
