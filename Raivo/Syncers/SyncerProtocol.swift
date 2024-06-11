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

protocol SyncerProtocol {
    
    var account: SyncerAccount? { get set }
    
    var challenge: SyncerChallenge? { get set }
    
    var name: String { get }
    
    var help: String { get }
    
    var errorHelp: String { get }
    
    var recordsRequireSync: Bool { get }
    
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
