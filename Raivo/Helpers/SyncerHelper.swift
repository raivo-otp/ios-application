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

/// A helper class for the synchronization providers
class SyncerHelper: BaseClass {
    
    /// The singleton instance for the SyncerHelper
    public static let shared = SyncerHelper()
    
    /// The syncers that are available and therefore allowed to use
    public static let availableSyncers = [
        OfflineSyncer.UNIQUE_ID,
        CloudKitSyncer.UNIQUE_ID
    ]
    
    /// Keeps track of all initialized syncers
    private var syncers: [String: SyncerProtocol] = [:]
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private override init() {}
    
    /// Get the selected, prefered or mock syncer (in that order, if available)
    ///
    /// - Parameter type: If you want a specific syncer, you can pass it's unique ID (e.g. `OfflineSyncer.UNIQUE_ID`)
    /// - Returns: A cached instance of the intended syncer
    public func getSyncer(_ type: String? = nil) -> SyncerProtocol {
        let intented = type ?? StorageHelper.shared.getSynchronizationProvider()
        
        if intented != nil && !SyncerHelper.availableSyncers.contains(type!) {
            fatalError(String(format: "Intended syncer `%@` does not exist.", intented!))
        }
        
        return (intented != nil) ? getOrCreateSyncer(intented!) : MockSyncer()
    }
    
    /// Get a syncer instance by type. If it doesn't exist, create it and cache it.
    ///
    /// - Parameter type: The type of syncer you want (e.g. `OfflineSyncer.UNIQUE_ID`)
    /// - Returns: A cached instance of the intended syncer
    private func getOrCreateSyncer(_ type: String) -> SyncerProtocol{
        if !syncers.keys.contains(type) {
            switch type {
            case OfflineSyncer.UNIQUE_ID:
                syncers[type] = OfflineSyncer()
            case CloudKitSyncer.UNIQUE_ID:
                syncers[type] = CloudKitSyncer()
            default:
                fatalError(String(format: "Intended syncer `%@` does not exist.", type))
            }
        }
        
        return syncers[type]!
    }
    
    /// Clear the cached syncers so they can be initialized again in a later stage.
    ///
    /// - Parameter dueToPINCodeChange: Positive if only certain keychain items should be removed.
    /// - Note: The `dueToPINCodeChange` parameter can be set to true on e.g. a PIN code change.
    public func clear(dueToPINCodeChange: Bool = false) {
        guard !dueToPINCodeChange else { return }
        
        syncers.removeAll()
    }
    
}
