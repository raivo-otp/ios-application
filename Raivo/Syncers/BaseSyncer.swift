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

class BaseSyncer {
    
    static let ACCOUNT_NOTIFICATION = Notification.Name(id(BaseSyncer.self) + "ACCOUNT_NOTIFICATION")
    
    static let CHALLENGE_NOTIFICATION = Notification.Name(id(BaseSyncer.self) + "CHALLENGE_NOTIFICATION")
    
    var enabled: Bool?
    
    var account: SyncerAccount?
    
    var challenge: SyncerChallenge?
    
    var accountPreloading: Bool = false
    
    var accountPreloaded: Bool = false
    
    var accountError: Error?
    
    var challengePreloading: Bool = false
    
    var challengePreloaded: Bool = false
    
    var challengeError: Error?
    
    func enable() {
        log.verbose("Enabling syncer")
        
        self.enabled = true
    }
    
    func disable() {
        log.verbose("Disabling syncer")
        
        self.enabled = false
        self.accountPreloaded = false
        self.accountPreloading = false
        self.challengePreloaded = false
        self.challengePreloading = false
    }

}
