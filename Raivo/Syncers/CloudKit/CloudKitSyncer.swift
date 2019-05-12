//
//  CloudKitSyncer.swift
//  Raivo
//
//  Created by Tijme Gommers on 04/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import CloudKit
import RealmSwift

class CloudKitSyncer: BaseSyncer, SyncerProtocol {
    
    @available(*, deprecated, renamed: "UNIQUE_ID")
    public static let DEPRECATED_ID = "CLOUD_KIT_SYNCER"
    
    var name = "Apple iCloud"
    
    var help = "Your Apple iCloud account is used to store your passwords (encrypted)."
  
    let modelSyncers = [
        Password.UNIQUE_ID: CloudKitPasswordSyncer()
    ]

    override func enable() -> Void {
        super.enable()
        enableModels()
    }
    
    override func disable() -> Void {
        super.disable()
        disableModels()
    }
    
    func notify(_ userInfo: [AnyHashable : Any]) {
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if notification.notificationType == .query {
            notifyModels(notification)
        }
    }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void {
        if accountPreloaded {
            accountError == nil ? success(account!, UNIQUE_ID) : error(accountError!, UNIQUE_ID)
        } else {
            NotificationCenter.default.addObserver(forName: BaseSyncer.ACCOUNT_NOTIFICATION, object: nil, queue: nil) { note in
                self.getAccount(success: success, error: error)
            }
            
            preloadAccount()
        }
    }
    
    func preloadAccount() {
        guard accountPreloaded == false && accountPreloading == false else {
            return
        }
        
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                return self.preloadAccountError(error)
            }
            
            self.preloadAccountSuccess(recordID)
        }
    }
    
    private func preloadAccountError(_ error: Error?) {
        self.account = nil
        self.accountError = error
        self.accountPreloaded = true
        self.accountPreloading = false
        
        NotificationCenter.default.post(name: BaseSyncer.ACCOUNT_NOTIFICATION, object: nil)
    }
    
    private func preloadAccountSuccess(_ recordID: CKRecord.ID) {
        self.account = SyncerAccount(name: "Personal iCloud", identifier: recordID.recordName)
        self.accountError = nil
        self.accountPreloaded = true
        self.accountPreloading = false
        
        NotificationCenter.default.post(name: BaseSyncer.ACCOUNT_NOTIFICATION, object: nil)
    }
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) {
        if challengePreloaded {
            challengeError == nil ? success(challenge!, UNIQUE_ID) : error(challengeError!, UNIQUE_ID)
        } else {
            NotificationCenter.default.addObserver(forName: BaseSyncer.CHALLENGE_NOTIFICATION, object: nil, queue: nil) { note in
                self.getChallenge(success: success, error: error)
            }
            
            preloadChallenge()
        }
    }
    
    func preloadChallenge() {
        guard challengePreloaded == false && challengePreloading == false else {
            return
        }
        
        let query = CKQuery(recordType: Password.TABLE, predicate: NSPredicate(format: "deleted == 0"))
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                return self.preloadChallengeError(error)
            }
            
            self.preloadChallengeSuccess(records)
        }
    }
    
    private func preloadChallengeError(_ error: Error?) {
        self.challenge = nil
        self.challengeError = error
        self.challengePreloaded = true
        self.challengePreloading = false
        
        NotificationCenter.default.post(name: BaseSyncer.CHALLENGE_NOTIFICATION, object: nil)
    }
    
    private func preloadChallengeSuccess(_ records: [CKRecord]) {
        if let firstRecord = records.first {
            self.challenge = SyncerChallenge(challenge: firstRecord.value(forKey: "issuer") as? String)
        } else {
            self.challenge = SyncerChallenge(challenge: nil)
        }
        
        self.challengeError = nil
        self.challengePreloaded = true
        self.challengePreloading = false
        
        NotificationCenter.default.post(name: BaseSyncer.CHALLENGE_NOTIFICATION, object: nil)
    }
    
    public func resyncModel(_ model: String) {
        modelSyncers[model]?.resyncAll()
    }
    
    func flushAllData(success: @escaping ((String) -> Void), error: @escaping ((Error, String) -> Void)) {
        let group = DispatchGroup()
        var modelError: Error? = nil
        
        for (_, modelSyncer) in modelSyncers {
            group.enter()

            modelSyncer.flushAllData(success: {
                group.leave()
            }, error: { newError in
                modelError = newError
                group.leave()
            })
        }

        group.notify(queue: .main) {
            if let modelError = modelError {
                error(modelError, self.UNIQUE_ID)
            } else {
                success(self.UNIQUE_ID)
            }
        }
    }
    
    internal func resyncModels() {
        for (_, modelSyncer) in modelSyncers {
            modelSyncer.resyncAll()
        }
    }
    
    internal func notifyModels(_ notification: CKQueryNotification?) {
        for (_, modelSyncer) in modelSyncers {
            modelSyncer.notify(notification)
        }
    }
    
    internal func enableModels() {
        for (_, modelSyncer) in modelSyncers {
            modelSyncer.enable()
        }
    }
    
    internal func disableModels() {
        for (_, modelSyncer) in modelSyncers {
            modelSyncer.disable()
        }
    }
    
}
