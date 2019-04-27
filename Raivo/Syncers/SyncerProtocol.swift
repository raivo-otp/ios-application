//
//  SyncerProtocol.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

protocol SyncerProtocol: BaseClass {
    
    var account: SyncerAccount? { get set }
    
    var challenge: SyncerChallenge? { get set }
    
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
