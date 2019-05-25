//
//  SyncerHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class SyncerHelperOld {
    
    private static var syncers: [String: SyncerProtocol] = [:]
    
    public static let availableSyncers = [
        OfflineSyncer.UNIQUE_ID,
        CloudKitSyncer.UNIQUE_ID
    ]
    
    public static func getSyncer(_ type: String? = nil) -> SyncerProtocol {
        let defaultSyncerType = StorageHelper.getSynchronizationProvider()
        let type = type ?? defaultSyncerType
        
        if type != nil && !availableSyncers.contains(type!) {
            fatalError("getSyncer(" + type! + "): SYNCER DOES NOT EXIST!")
        }
        
        if type == nil {
            return MockSyncer()
        }
        
        return getOrCreateSyncer(type!)
    }
    
    private static func getOrCreateSyncer(_ type: String) -> SyncerProtocol{
        if !syncers.keys.contains(type) {
            switch type {
            case OfflineSyncer.UNIQUE_ID:
                syncers[type] = OfflineSyncer()
            case CloudKitSyncer.UNIQUE_ID:
                syncers[type] = CloudKitSyncer()
            default:
                fatalError("getSyncer(" + type + "): SYNCER DOES NOT EXIST!")
            }
        }
       
        return syncers[type]!
    }
    
    public static func clear(dueToPINCodeChange: Bool = false) {
        guard !dueToPINCodeChange else { return }
        
        syncers.removeAll()
    }
    
}
