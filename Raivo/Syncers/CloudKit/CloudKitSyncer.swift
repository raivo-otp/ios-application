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
import CloudKit
import RealmSwift

class CloudKitSyncer: BaseSyncer, SyncerProtocol {
    
    //public static let containerName = "iCloud.com.finnwea.Raivo"
	public static let containerName = "iCloud.com.finnwea.Raivo"
        
    var name = "Apple iCloud"
    
    var help = "Your Apple iCloud account is used to store your passwords (encrypted). Consult the iCloud account settings in iOS to check which account is being used."
    
    var errorHelp = "Enable 'iCloud Drive' in iPhone settings to enable Apple iCloud."
    
    var recordsRequireSync = true
    
    let modelSyncers = [
        id(Password.self): CloudKitPasswordSyncer()
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
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])!
        
        if notification.notificationType == .query {
            notifyModels(notification)
        }
    }
    
    func getAccount(success: @escaping ((SyncerAccount, String) -> Void), error: @escaping ((Error, String) -> Void)) -> Void {
        if accountPreloaded {
            accountError == nil ? success(account!, id(self)) : error(accountError!, id(self))
        } else {
            NotificationHelper.shared.listenOnce(to: BaseSyncer.ACCOUNT_NOTIFICATION) { _ in
                self.getAccount(success: success, error: error)
            }
            
            preloadAccount()
        }
    }
    
    func preloadAccount() {
        guard accountPreloaded == false && accountPreloading == false else {
            return
        }
        
        CKContainer.init(identifier: CloudKitSyncer.containerName).fetchUserRecordID { recordID, error in
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
        self.account = SyncerAccount(name: self.name, identifier: recordID.recordName)
        self.accountError = nil
        self.accountPreloaded = true
        self.accountPreloading = false
        
        NotificationCenter.default.post(name: BaseSyncer.ACCOUNT_NOTIFICATION, object: nil)
    }
    
    func getChallenge(success: @escaping ((SyncerChallenge, String) -> Void), error: @escaping ((Error, String) -> Void)) {
        if challengePreloaded {
            challengeError == nil ? success(challenge!, id(self)) : error(challengeError!, id(self))
        } else {
            NotificationHelper.shared.listenOnce(to: BaseSyncer.CHALLENGE_NOTIFICATION) { _ in
                self.getChallenge(success: success, error: error)
            }
            
            preloadChallenge()
        }
    }
    
    func preloadChallenge() {
        guard challengePreloaded == false && challengePreloading == false else {
            return
        }
        
        let query = CKQuery(recordType: Password.TABLE, predicate: NSPredicate(value: true))
        CKContainer.init(identifier: CloudKitSyncer.containerName).privateCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                return self.preloadChallengeError(error)
            }
            
            self.preloadChallengeSuccess(records.filter { $0.value(forKey: "deleted") as! Int64 == 0 })
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
        log.warning("Flushing all data remotely")
        
        let group = DispatchGroup()
        var modelError: Error? = nil
        
        for (_, modelSyncer) in modelSyncers {
            group.enter()
            
            log.warning("Flushing all data remotely specifically for model " + id(modelSyncer) + ".")
            modelSyncer.flushAllData(success: {
                group.leave()
            }, error: { newError in
                modelError = newError
                group.leave()
            })
        }

        group.notify(queue: .main) {
            if let modelError = modelError {
                error(modelError, id(self.self))
            } else {
                success(id(self.self))
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
        log.verbose("Enabling account change listener")
        
        NotificationHelper.shared.listen(to: .CKAccountChanged, distinctBy: id(self)) { _ in
            log.verbose("CKAccountChanged notification")
            
            self.accountPreloaded = false
            
            self.getAccount(success: { (account, syncerID) in
                DispatchQueue.main.async {
                    guard account.identifier != StorageHelper.shared.getSynchronizationAccountIdentifier() else {
                        return
                    }
                    
                    log.verbose("New iCloud account differs from current account")
                    
                    getAppDelegate().syncerAccountIdentifier = account.identifier
                    getAppDelegate().updateStoryboard()
                }
            }, error: { (error, syncerID) in
                DispatchQueue.main.async {
                    log.verbose("Couldn't get iCloud account")
                    
                    getAppDelegate().syncerAccountIdentifier = nil
                    getAppDelegate().updateStoryboard()
                }
            })
        }
    }
    
    private func disableAccountChangeListener() {
        log.verbose("Disabling account change listener")
        
        NotificationHelper.shared.discard(.CKAccountChanged, byDistinctName: id(self))
    }
    
}
