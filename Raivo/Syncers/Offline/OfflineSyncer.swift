//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import RealmSwift

class OfflineSyncer: BaseSyncer, SyncerProtocol {
    
    var name = "None (offline)"
    
    var help = "Synchronisation is disabled. You can't change this after setup."
    
    var errorHelp = ""
    
    var recordsRequireSync = false
    
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
        
        success(account!, id(self))
    }
    
    func preloadAccount() {
        if !accountPreloaded {
            accountPreloading = false
            
            account = SyncerAccount(
                name: self.name,
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
        
        success(challenge!, id(self))
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
        autoreleasepool {
            if let realm = try? RealmHelper.shared.getRealm() {
                try? RealmHelper.shared.writeBlock(realm) {
                    realm.deleteAll()
                }
            }
        }
        
        success(id(self))
    }
    
}
