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
import RealmSwift

class RealmHelper {
    
    private static let ORIGINAL_URL = Realm.Configuration.defaultConfiguration.fileURL
    
    public static func getRealm() -> Realm? {
        if let _ = Realm.Configuration.defaultConfiguration.encryptionKey {
            return try! Realm()
        }
        
        return nil
    }
    
    public static func initDefaultRealmConfiguration(encryptionKey: Data?) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            fileURL: getFileURL(),
            encryptionKey: encryptionKey,
            schemaVersion: UInt64(AppHelper.build) + 1,
            migrationBlock: { migration, oldSchemaVersion in
                var oldVersion = oldSchemaVersion
                let newVersion = UInt64(AppHelper.build) + 1

                while oldVersion < newVersion {
                    if let migrate = MigrationHelper.migrations[Int(oldVersion)] {
                        migrate.migrateRealm(migration)
                    }
                    
                    oldVersion += 1
                }
            }
        )
    }
    
    public static func getFileURL(forceFilename: String? = nil) -> URL? {
        // Unfortunetely we must open a different realm file after logout, because Realm does not
        // auto release the internal cached references to the database (it keeps the connection
        // open at all time). Manually `.invalidating()` them does not work.
        // https://stackoverflow.com/a/54140362/2491049
        
        if let filename = forceFilename {
            return ORIGINAL_URL!.deletingLastPathComponent().appendingPathComponent(filename)
        }
        
        if let realmfile = StorageHelper.shared.getRealmFilename() {
            return ORIGINAL_URL!.deletingLastPathComponent().appendingPathComponent(realmfile)
        }
        
        let realmfile = String(Int(Date().timeIntervalSince1970)) + ".realm"
        StorageHelper.shared.setRealmFilename(realmfile)
        
        return getFileURL()
    }
    
    public static func getProposedNewFileName() -> String {
        return String(Int(Date().timeIntervalSince1970)) + ".realm"
    }
    
    public static func fileURLExists() -> Bool {
        if let fileURL = getFileURL() {
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        return false
    }
    
    public static func isCorrectEncryptionKey(_ encryptionKey: Data?) -> Bool {
        // Realm exceptions can't be caught, therefore copy the DB and try to unlock it, afterwards delete that file.
        // https://stackoverflow.com/questions/37014101/realm-swift-how-to-catch-rlmexception
        
        if let encryptionKey = encryptionKey {
            RealmHelper.initDefaultRealmConfiguration(encryptionKey: encryptionKey)
            
            let originalURL = Realm.Configuration.defaultConfiguration.fileURL!
            let unlockURL = originalURL.appendingPathExtension("unlockme")
            
            var unlockConfiguration = Realm.Configuration.defaultConfiguration
            unlockConfiguration.fileURL = unlockURL
            
            var result = false
            
            do {
                try FileManager.default.copyItem(at: originalURL, to: unlockURL)
                let _ = try Realm(configuration: unlockConfiguration)
                result = true
            } catch {
                result = false
            }
            
            try? FileManager.default.removeItem(at: unlockURL)
            try? FileManager.default.removeItem(at: unlockURL.appendingPathExtension("lock"))
            try? FileManager.default.removeItem(at: unlockURL.appendingPathExtension("note"))
            try? FileManager.default.removeItem(at: unlockURL.appendingPathExtension("management"))
            
            return result
        }
        
        return false
    }
    
}
