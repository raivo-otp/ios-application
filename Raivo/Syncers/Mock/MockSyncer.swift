//
//  MockSyncer.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class MockSyncer: BaseSyncer, SyncerProtocol {
    
    var name = "None (mock)"
    
    var help = "Synchronization is currently disabled."
    
    func notify(_ userInfo: [AnyHashable : Any]) {
        // Not implemented
    }
    
    public func resyncModel(_ model: String) {
        // Not implemented
    }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void {
        error(UnexpectedError("This is the mock syncer!"), UNIQUE_ID)
    }
   
    func preloadAccount() {
        // Not implemented
    }
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) {
        error(UnexpectedError("This is the mock syncer!"), UNIQUE_ID)
    }
    
    func preloadChallenge() {
        // Not implemented
    }
    
    func flushAllData(success: @escaping ((String) -> Void), error: @escaping ((Error, String) -> Void)) {
        error(UnexpectedError("This is the mock syncer!"), UNIQUE_ID)
    }
    
}
