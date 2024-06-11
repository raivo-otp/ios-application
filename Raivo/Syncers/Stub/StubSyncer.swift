//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation

class StubSyncer: BaseSyncer, SyncerProtocol {
    
    var name = "None (stub)"
    
    var help = "Synchronisation is currently disabled."
    
    var errorHelp = ""
    
    var recordsRequireSync = false
    
    func notify(_ userInfo: [AnyHashable : Any]) {
        // Not implemented
    }
    
    public func resyncModel(_ model: String) {
        // Not implemented
    }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void {
        error(UnexpectedError.vitalFunctionalityIsStub, id(self))
    }
   
    func preloadAccount() {
        // Not implemented
    }
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) {
        error(UnexpectedError.vitalFunctionalityIsStub, id(self))
    }
    
    func preloadChallenge() {
        // Not implemented
    }
    
    func flushAllData(success: @escaping ((String) -> Void), error: @escaping ((Error, String) -> Void)) {
        error(UnexpectedError.vitalFunctionalityIsStub, id(self))
    }
    
}
