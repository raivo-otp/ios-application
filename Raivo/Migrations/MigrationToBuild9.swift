//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

import Foundation
import RealmSwift

/// A class for migrating and rolling back changes for the corresponding build.
class MigrationToBuild9: MigrationProtocol {

    /// The build number belonging to this migration.
    static var build: Int = 9
    
    /// Run Realm migrations to make data compatible with this build.
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        // Not implemented
    }
    
    /// Run migrations to make data compatible with this build (before app initialization).
    func migratePreInitialize() {
        log.warning("Running pre init migration...")
        
        // Not implemented
    }
    
    /// Run generic migrations to make data compatible with this build.
    func migrateGeneric() {
        log.verbose("Running Build9 migrations...")
        
        migrateSyncerTypeInStorage()
    }
    
    /// This build does not require generic migrations using the syncer account.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    func migrateGeneric(with account: SyncerAccount) {
        log.verbose("Running Build9 migrations using the syncer account...")
        
        migrateSyncerAccountIdentifierInStorage(with: account)
    }
    
    /// Migrate the syncer identifier that is currently stored.
    ///
    /// - Note: This migration converts e.g. `OFFLINE_SYNCER` to `id(OfflineSyncer.self)`.
    private func migrateSyncerTypeInStorage() {
        guard let syncerType = StorageHelper.shared.getSynchronizationProvider() else {
            return
        }
            
        guard ["OFFLINE_SYNCER", "CLOUD_KIT_SYNCER"].contains(syncerType) else {
            return
        }
        
        var newSyncerType: String
        
        switch syncerType {
        case "CLOUD_KIT_SYNCER":
            newSyncerType = id(CloudKitSyncer.self)
        case "OFFLINE_SYNCER":
            newSyncerType = id(OfflineSyncer.self)
        default:
            return
        }
        
        StorageHelper.shared.setSynchronizationProvider(newSyncerType)
    }
    
    /// Store the current synchronization identifier in storage.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    /// - Note: This will be used to identify account changes.
    private func migrateSyncerAccountIdentifierInStorage(with account: SyncerAccount) {
        StorageHelper.shared.setSynchronizationAccountIdentifier(account.identifier)
    }
    
}
