//
//  RealmHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 02/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    private static let ORIGINAL_URL = Realm.Configuration.defaultConfiguration.fileURL
    
    public static func initDefaultRealmConfiguration(encryptionKey: Data?) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            fileURL: getFileURL(),
            encryptionKey: encryptionKey,
            schemaVersion: UInt64(AppHelper.build) + 1,
            migrationBlock: { migration, oldSchemaVersion in
                // Walk through every migration that is needed
                if (oldSchemaVersion < 6) { MigrationHelper.migrations[6]?.migrateRealm(migration) }
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
        if let encryptionKey = encryptionKey {
            RealmHelper.initDefaultRealmConfiguration(encryptionKey: encryptionKey)
            
            do {
                let _ = try Realm(configuration: Realm.Configuration.defaultConfiguration)
                return true
            } catch {
                return false
            }
        }
        
        return false
    }
    
}
