//
//  SyncerHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class SyncerHelper {
    
    private static var syncers: [String: SyncerProtocol] = [:]
    
    public static let availableSyncers = [
        OfflineSyncer.UNIQUE_ID,
        CloudKitSyncer.UNIQUE_ID
    ]
    
    public static func getSyncer(_ type: String? = nil) -> SyncerProtocol {
        let defaultSyncerType = KeychainHelper.settings().string(forKey: KeychainHelper.KEY_SYNCHRONIZATION_PROVIDER)
        let type = type ?? defaultSyncerType
        
        if type != nil && !availableSyncers.contains(type!) {
            if ![OfflineSyncer.DEPRECATED_ID, CloudKitSyncer.DEPRECATED_ID].contains(type!) {
                fatalError("getSyncer(" + type! + "): SYNCER DOES NOT EXIST!")
            }
        }
        
        if type == nil {
            return MockSyncer()
        }
        
        return getOrCreateSyncer(type!)
    }
    
    private static func getOrCreateSyncer(_ type: String) -> SyncerProtocol{
        if !syncers.keys.contains(type) {
            switch type {
            case OfflineSyncer.UNIQUE_ID, OfflineSyncer.DEPRECATED_ID:
                syncers[type] = OfflineSyncer()
            case CloudKitSyncer.UNIQUE_ID, CloudKitSyncer.DEPRECATED_ID:
                syncers[type] = CloudKitSyncer()
            default:
                fatalError("getSyncer(" + type + "): SYNCER DOES NOT EXIST!")
            }
        }
       
        return syncers[type]!
    }
    
    public static func clear() {
        syncers.removeAll()
    }
    
}
