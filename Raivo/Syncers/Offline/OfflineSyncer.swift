//
//  OfflineSyncer.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class OfflineSyncer: BaseSyncer, SyncerProtocol {
    
    @available(*, deprecated, renamed: "UNIQUE_ID")
    public static let DEPRECATED_ID = "OFFLINE_SYNCER"
    
    var name = "None (offline)"
    
    var help = "Synchronization is currently disabled."
    
    func notify(_ userInfo: [AnyHashable : Any]) {
        // Not implemented
    }
    
    public func resyncModel(_ model: String) {
        // Not implemented
    }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void {
        if !accountPreloaded {
            self.preloadAccount()
        }
        
        success(account!, UNIQUE_ID)
    }
    
    func preloadAccount() {
        if !accountPreloaded {
            accountPreloading = false
            
            account = SyncerAccount(
                name: "None (offline)",
                identifier: "Offline"
            )
            
            accountPreloaded = true
            accountPreloading = false
        }
    }
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) {
        if !challengePreloaded {
            self.preloadChallenge()
        }
        
        success(challenge!, UNIQUE_ID)
    }
    
    func preloadChallenge() {
        if !challengePreloaded {
            challengePreloading = false
            
            challenge = SyncerChallenge(challenge: nil)
            
            challengePreloaded = true
            challengePreloading = false
        }
    }
    
    func flushAllData(success: @escaping ((String) -> Void), error: @escaping ((Error, String) -> Void)) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        
        success(UNIQUE_ID)
    }
    
}
