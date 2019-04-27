//
//  Migration4.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainSwift

class Migration4: MigrationProtocol {

    static var build: Int = 4
    
    let keychainMigrations = [
        StorageHelper.KEY_PASSWORD: "salt",
        StorageHelper.KEY_LOCKSCREEN_TIMEOUT: "inactivity_lock",
        StorageHelper.KEY_REALM_FILENAME: "realm_file",
        StorageHelper.KEY_SYNCHRONIZATION_PROVIDER: "syncer",
        StorageHelper.KEY_PINCODE_TRIED_AMOUNT: "pincode_tries_amount",
        StorageHelper.KEY_PINCODE_TRIED_TIMESTAMP: "pincode_last_try_timestamp",
    ]
    
    /// This build does not require Realm migrations
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    ///
    /// - Note: Method      
    func migrateRealm(_ migration: Migration) {
    }
    
    func migrateGeneric() {
        doMigrateKeychain()
    }
    
    func hasToMigrate() -> Bool {
        for newKey in keychainMigrations.keys {
            let oldKey = keychainMigrations[newKey]!
            if let _ = KeychainSwift().get(oldKey) {
                return true
            }
        }
            
        return false
    }
    
    /// Migrate from KeychainSwift to Valet, as Valet is more advanced and e.g. provides functionality to save data in Secure Enclave.
    ///
    /// - Note: KeychainSwift: https://github.com/evgenyneu/keychain-swift
    /// - Note: Valet: https://github.com/square/Valet
    internal func doMigrateKeychain() {
        for newKey in keychainMigrations.keys {
            let oldKey = keychainMigrations[newKey]!
            if let value = KeychainSwift().get(oldKey) {
                StorageHelper.settings().set(string: value, forKey: newKey)
                KeychainSwift().delete(oldKey)
            }
        }
    }
    
}
