//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

import Foundation

/// A helper class for the synchronization providers
class SyncerHelper {
    
    /// The singleton instance for the SyncerHelper
    public static let shared = SyncerHelper()
    
    /// The syncers that are available and therefore allowed to use
    public static let availableSyncers = [
        id(OfflineSyncer.self),
        id(CloudKitSyncer.self)
    ]
    
    /// Keeps track of all initialized syncers
    private var syncers: [String: SyncerProtocol] = [:]
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Get the selected, prefered or mock syncer (in that order, if available)
    ///
    /// - Parameter type: If you want a specific syncer, you can pass it's unique ID (e.g. `id(OfflineSyncer.self)`)
    /// - Returns: A cached instance of the intended syncer
    public func getSyncer(_ type: String? = nil) -> SyncerProtocol {
        let intented = type ?? StorageHelper.shared.getSynchronizationProvider()
        
        if intented != nil && !SyncerHelper.availableSyncers.contains(intented!) {
            log.error(String(format: "Intended syncer `%@` does not exist.", intented!))
            fatalError(String(format: "Intended syncer `%@` does not exist.", intented!))
        }
        
        return (intented != nil) ? getOrCreateSyncer(intented!) : StubSyncer()
    }
    
    /// Get a syncer instance by type. If it doesn't exist, create it and cache it.
    ///
    /// - Parameter type: The type of syncer you want (e.g. `id(OfflineSyncer.self)`)
    /// - Returns: A cached instance of the intended syncer
    private func getOrCreateSyncer(_ type: String) -> SyncerProtocol{
        if !syncers.keys.contains(type) {
            switch type {
            case id(OfflineSyncer.self):
                syncers[type] = OfflineSyncer()
            case id(CloudKitSyncer.self):
                syncers[type] = CloudKitSyncer()
            default:
                log.error(String(format: "Intended syncer `%@` does not exist.", type))
                fatalError(String(format: "Intended syncer `%@` does not exist.", type))
            }
        }
        
        return syncers[type]!
    }
    
    /// Clear the cached syncers so they can be initialized again in a later stage.
    ///
    /// - Parameter dueToPasscodeChange: Positive if only certain keychain items should be removed.
    /// - Note: The `dueToPasscodeChange` parameter can be set to true on e.g. a passcode change.
    public func clear(dueToPasscodeChange: Bool = false) {
        guard !dueToPasscodeChange else { return }
        
        syncers.removeAll()
    }
    
}
