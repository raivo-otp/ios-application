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
import RealmSwift

/// A helper class for managing the Realm instance
class RealmHelper {
    
    /// The singleton instance for the RealmHelper
    public static let shared = RealmHelper()
    
    /// The path to the default Realm file
    private let ORIGINAL_URL = Realm.Configuration.defaultConfiguration.fileURL
    
    /// The database schema version (increase to latest `AppHelper.build` to migrate)
    private let SCHEMA_VERSION = UInt64(69)
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Get the current Realm instances with the default configuration
    ///
    /// - Parameter feedbackOnError: Positive if feedback should be shown to the user if the initialization fails.
    /// - Returns: The Realm instance to use
    /// - Throws: `NSerror` if realm instance could not be created
    /// - Note Returns nil if the encryption key is unknown
    public func getRealm(feedbackOnError: Bool = true) throws -> Realm? {
        let currentConfig = Realm.Configuration.defaultConfiguration
        
        guard let _ = currentConfig.encryptionKey else {
            return nil
        }
        
        do {
            return try Realm(configuration: currentConfig)
        } catch {
            log.error("A Realm Objective-C instance could not be created: " + error.localizedDescription)
            
            if feedbackOnError {
                ui { BannerHelper.shared.error("Something went wrong", "Could not connect to the database") }
            }
            
            throw error
        }
    }
    
    /// Fail safe write block for Realms.
    ///
    /// - Parameter realm: A previously initialized realm instance.
    /// - Parameter feedbackOnError: Positive if feedback should be shown to the user if the initialization fails.
    ///    /// - Parameter callback: Called after the given duration.
    public func writeBlock(_ realm: Realm, feedbackOnError: Bool = true, callback: (() -> Void)) throws {
        do {
            try realm.write {
                callback()
            }
        } catch {
            log.error("Could not write to the Realm Objective-C instance: " + error.localizedDescription)
            
            if feedbackOnError {
                ui { BannerHelper.shared.error("Something went wrong", "Could not write to the database") }
            }
            
            throw error
        }
    }
    
    /// Update the default Realm configuration to use the given encryption key
    ///
    /// - Parameter encryptionKey: Used to decrypt the Realm file
    /// - Note This method will run Realm migrations (if any)
    public func initDefaultRealmConfiguration(encryptionKey: Data?) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            fileURL: getFileURL(),
            encryptionKey: encryptionKey,
            schemaVersion: self.SCHEMA_VERSION,
            migrationBlock: { migration, oldSchemaVersion in
                var oldVersion = oldSchemaVersion
                let newVersion = self.SCHEMA_VERSION

                while oldVersion < newVersion {
                    if let migrate = MigrationHelper.shared.migrations[Int(oldVersion)] {
                        migrate.migrateRealm(migration)
                    }
                    
                    oldVersion += 1
                }
            }
        )
    }
    
    /// Get the filename of the current Realm file (from storage) or a new one.
    ///
    /// - Parameter forceFilename: If given, this will be used as the filename in the path to the Realm file
    /// - Returns: A URL (path) to the requested Realm file
    /// - Note Unfortunetely we must open a different realm file after logout, because Realm does not auto release the internal cached references to the database.
    ///         It keeps the connection open at all time. Manually `.invalidating()` them does not work.
    ///         https://stackoverflow.com/a/54140362/2491049
    public func getFileURL(forceFilename: String? = nil) -> URL? {
        if let filename = forceFilename {
            return ORIGINAL_URL!.deletingLastPathComponent().appendingPathComponent(filename)
        }
        
        if let realmfile = StorageHelper.shared.getRealmFilename() {
            return ORIGINAL_URL!.deletingLastPathComponent().appendingPathComponent(realmfile)
        }
        
        let realmfile = String(Int(Date().timeIntervalSince1970)) + ".realm"
        try! StorageHelper.shared.setRealmFilename(realmfile)
        
        return getFileURL()
    }
    
    /// Get a proposed new (unique) filename for Realm (based on the timestamp)
    ///
    /// - Returns: A string with the unix timestamp and a Realm extension (filetype)
    public func getProposedNewFileName() -> String {
        return String(Int(Date().timeIntervalSince1970)) + ".realm"
    }
    
    /// Check if the current Realm file (from `getFileURL()` exists
    ///
    /// - Returns: Positive if it exists, false otherwise
    public func fileURLExists() -> Bool {
        if let fileURL = getFileURL() {
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        return false
    }
    
    /// Check if the given encryption key can unlock the current Realm database
    ///
    /// - Parameter encryptionKey: The encryption key to try
    /// - Returns: Positive if it is the correct key, false otherwise
    /// - Note Realm exceptions can't be caught, therefore copy the DB and try to unlock it, afterwards delete that file
    ///         https://stackoverflow.com/questions/37014101/realm-swift-how-to-catch-rlmexception
    public func isCorrectEncryptionKey(_ encryptionKey: Data?) -> Bool {
        if let encryptionKey = encryptionKey {
            initDefaultRealmConfiguration(encryptionKey: encryptionKey)
            
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
