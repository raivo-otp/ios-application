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
import Valet

/// A class for migrating and rolling back changes for the corresponding build.
class MigrationToBuild60: MigrationProtocol {

    /// The build number belonging to this migration.
    static var build: Int = 60
    
    /// Run Realm migrations to make data compatible with this build.
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        log.warning("Running Realm migration...")
        
        // Not implemented
    }
    
    /// A migration function that is always called, for all builds, on every startup.
    ///
    /// - Note: Only required when e.g. migrating (keychain) items that are referenced before initialization of the app
    /// - Note: This migration function includes its own conditionals for when to be executed.
    func migratePreBoot() {
        do {
            // Try to get one item that should exist in the Keychain (stored with `afterFirstUnlock`) if the migration already ran.
            let valet = Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .afterFirstUnlock)
            let realmFilenameInGlobals = (try? valet.string(forKey: StorageHelper.Key.REALM_FILENAME)) ?? ""
            
            // If it doesn't exist, we should run the migration. We can even do this if this is the first install, as it will have no further effect.
            if realmFilenameInGlobals.count < 1 {
                try Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .afterFirstUnlock)
                    .migrateObjectsFromAlwaysAccessibleValet(removeOnCompletion: true)
                
                log.info("Migrated Valet from version 3 to version 4")
            }
        } catch KeychainError.itemNotFound {
            log.verbose("No items found to migrate during pre-boot Valet migration.")
        } catch {
            log.error("Unexpected pre-boot Valet migration error: \(error).")
        }
    }
    
    /// Run migrations to make data compatible with this build (before app initialization).
    ///
    /// - Throws: Migration exceptions on fail
    func migratePreInitialize() throws {
        log.warning("Running pre init migration...")
        
        // Not implemented
    }
    
    /// Run generic migrations to make data compatible with this build.
    ///
    /// - Throws: Migration exceptions on fail
    func migrateGeneric() throws {
        log.warning("Running generic migration...")
        
        // Not implemented
    }
    
    /// This build does not require generic migrations using the syncer account.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    func migrateGeneric(with account: SyncerAccount) {
        log.warning("Running generic migration with syncer account...")
        
        // Not implemented
    }
    
}
