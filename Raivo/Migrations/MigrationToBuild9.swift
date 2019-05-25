//
//  MigrationToBuild9.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class MigrationToBuild9: MigrationProtocol {
    
    static var build: Int = 9
    
    /// This build does not require Realm migrations
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        
    }
    
    /// Run the migrations that are needed to succesfully use this build after an update
    func migrateGeneric() {
        migrateSyncerTypeInStorage()
    }
    
    /// Run the migrations that are needed to succesfully use this build after an update
    func migrateGeneric(withAccount: SyncerAccount) {
        migrateSyncerAccountIdentifierInStorage(withAccount)
    }
    
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
            newSyncerType = CloudKitSyncer.UNIQUE_ID
        case "OFFLINE_SYNCER":
            newSyncerType = OfflineSyncer.UNIQUE_ID
        default:
            return
        }
        
        StorageHelper.shared.setSynchronizationProvider(newSyncerType)
    }
    
    private func migrateSyncerAccountIdentifierInStorage(_ account: SyncerAccount) {
        StorageHelper.shared.setSynchronizationAccountIdentifier(account.identifier)
    }
    
}
