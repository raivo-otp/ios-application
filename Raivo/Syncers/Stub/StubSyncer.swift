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

class StubSyncer: BaseSyncer, SyncerProtocol {
    
    var name = "None (stub)"
    
    var help = "Synchronization is currently disabled."
    
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
