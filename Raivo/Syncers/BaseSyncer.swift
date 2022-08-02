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
