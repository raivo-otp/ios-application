//
//  BaseSyncer.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class BaseSyncer: BaseClass {
    
    static let ACCOUNT_NOTIFICATION = Notification.Name(BaseSyncer.UNIQUE_ID + "ACCOUNT_NOTIFICATION")
    
    static let CHALLENGE_NOTIFICATION = Notification.Name(BaseSyncer.UNIQUE_ID + "CHALLENGE_NOTIFICATION")
    
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
        self.enabled = true
    }
    
    func disable() {
        self.enabled = false
        self.accountPreloaded = false
        self.accountPreloading = false
        self.challengePreloaded = false
        self.challengePreloading = false
    }

}
