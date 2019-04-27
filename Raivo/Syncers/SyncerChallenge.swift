//
//  SyncerChallenge.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class SyncerChallenge {
    
    let challenge: String?
    
    init(challenge: String?) {
        self.challenge = challenge
    }
    
    func hasChallenge() -> Bool {
        return challenge != nil
    }
    
}
