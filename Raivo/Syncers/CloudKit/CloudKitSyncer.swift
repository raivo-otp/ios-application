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
        
    var name = "Apple iCloud"
    
    var help = "Your Apple iCloud account is used to store your passwords (encrypted)."
    
    let modelSyncers = [
        Password.UNIQUE_ID: CloudKitPasswordSyncer()
    ]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func enable() -> Void {
        super.enable()
        enableModels()
        enableAccountChangeListener()
    }
    
    override func disable() -> Void {
        super.disable()
        disableModels()
        disableAccountChangeListener()
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
            NotificationHelper.shared.listenOnce(to: BaseSyncer.ACCOUNT_NOTIFICATION) {
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
            NotificationHelper.shared.listenOnce(to: BaseSyncer.CHALLENGE_NOTIFICATION) {
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
    
    private func enableAccountChangeListener() {
        NotificationHelper.shared.listen(to: .CKAccountChanged, distinctBy: UNIQUE_ID) {
            self.accountPreloaded = false
            
            self.getAccount(success: { (account, syncerID) in
                DispatchQueue.main.async {
                    guard account.identifier != StorageHelper.shared.getSynchronizationAccountIdentifier() else {
                        return
                    }
                    
                    self.getAppDelagate().syncerAccountIdentifier = account.identifier
                    self.getAppDelagate().updateStoryboard()
                }
            }, error: { (error, syncerID) in
                DispatchQueue.main.async {
                    self.getAppDelagate().syncerAccountIdentifier = nil
                    self.getAppDelagate().updateStoryboard()
                }
            })
        }
    }
    
    private func disableAccountChangeListener() {
        NotificationHelper.shared.discard(.CKAccountChanged, byDistinctName: UNIQUE_ID)
    }
    
}
