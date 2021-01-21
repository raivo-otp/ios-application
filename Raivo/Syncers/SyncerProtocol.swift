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

protocol SyncerProtocol {
    
    var account: SyncerAccount? { get set }
    
    var challenge: SyncerChallenge? { get set }
    
    var name: String { get }
    
    var help: String { get }
    
    var accountPreloading: Bool { get set }
    
    var accountPreloaded: Bool { get set }
    
    var accountError: Error? { get set }
    
    var challengePreloading: Bool { get set }
    
    var challengePreloaded: Bool { get set }
    
    var challengeError: Error? { get set }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void
    
    func flushAllData(success: @escaping ((String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void
    
    func preloadAccount() -> Void
    
    func preloadChallenge() -> Void
    
    func enable() -> Void
 
    func disable() -> Void
    
    func notify(_ userInfo: [AnyHashable : Any]) -> Void
    
    func resyncModel(_ model: String) -> Void
    
}
