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
            newSyncerType = id(CloudKitSyncer.self)
            newSyncerType = id(CloudKitSyncer.self)
        case "OFFLINE_SYNCER":
            newSyncerType = id(OfflineSyncer.self)
        default:
            return
        }
        
        StorageHelper.shared.setSynchronizationProvider(newSyncerType)
    }
    
    private func migrateSyncerAccountIdentifierInStorage(_ account: SyncerAccount) {
        StorageHelper.shared.setSynchronizationAccountIdentifier(account.identifier)
    }
    
}
