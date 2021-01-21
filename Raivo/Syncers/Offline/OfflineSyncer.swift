//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import RealmSwift

class OfflineSyncer: BaseSyncer, SyncerProtocol {
    
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
        
        success(account!, id(self))
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
            if let realm = RealmHelper.shared.getRealm() {
                try! realm.write {
                    realm.deleteAll()
                }
            }
        }
        
        success(id(self))
    }
    
}
