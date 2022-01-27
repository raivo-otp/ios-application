//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
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
