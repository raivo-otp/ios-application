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
import RealmSwift
import CloudKit

class CloudKitPasswordSyncer: CloudKitModelSyncerProtocol {

    private let cloud = CKContainer.init(identifier: CloudKitSyncer.containerName).privateCloudDatabase
    
    private var localNotifications: NotificationToken?
    
    private var localResults: Results<Password>?
    
    deinit {
        disable()
    }
    
    func enable() {
        disable()
        
        autoreleasepool {
            if let realm = RealmHelper.shared.getRealm() {
                localResults = realm.objects(Password.self).filter("syncing == 1")
                localNotifications = localResults!.observe(onLocalChange)
            }
        }
        
        subscribeToCloudKitChanges()
    }
    
    func disable() {
        localNotifications?.invalidate()
        localResults = nil
    }
    
    func resync(_ record: CKRecord.ID) {
        let reference = CKRecord.Reference(recordID: record, action: .none)
        let predicate = NSPredicate(format: "%K == %@", "recordID", reference)
        
        resyncAll(predicate)
    }
    
    func resyncAll(_ predicate: NSPredicate? = nil) {
        let predicate = predicate ?? NSPredicate(value: true)
        let query = CKQuery(recordType: Password.TABLE, predicate: predicate)
        
        cloud.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else {
                log.error(error?.localizedDescription ?? "Unknown CloudKit error!")
                return
            }
            
            guard StateHelper.shared.getCurrentState() == StateHelper.State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE else {
                log.error(error?.localizedDescription ?? "CloudKit sync finished but app is not unlocked anymore!")
                return
            }
            
            autoreleasepool {
                guard let realm = RealmHelper.shared.getRealm() else {
                    log.error("CloudKit sync finished but app is not unlocked anymore!")
                    return
                }
            
                for record in records {
                    do {
                        let local = try CloudKitPasswordConverter.getLocal(record)
                        
                        guard local == nil || (local?.synced == true && local?.syncing == false) else {
                            // Do not save passwords that still have to be synced
                            self.onLocalChange(local!)
                            continue
                        }
                        
                        let copy = try CloudKitPasswordConverter.getLocalCopy(record, syncedCorrectly: true)
                        
                        try! realm.write {
                            realm.add(copy, update: .modified)
                        }
                    } catch let error {
                        log.error(error.localizedDescription)
                        break
                    }
                }
            }
        }
    }
    
    func notify(_ notification: CKQueryNotification?) {
        guard notification?.subscriptionID == idr(CloudKitPasswordSyncer.self) else {
            return
        }
        
        guard let recordID = notification?.recordID else {
            return
        }
 
        resync(recordID)
    }
    
    func flushAllData(success: @escaping (() -> Void), error: @escaping ((Error) -> Void)) {
        let query = CKQuery(recordType: Password.TABLE, predicate: NSPredicate(value: true))
        
        cloud.perform(query, inZoneWith: nil) { (getResRecords, getResError) in
            guard let getResRecords = getResRecords, getResError == nil else {
                error(getResError ?? UnexpectedError.noErrorButNotSuccessful("Unknown CloudKit error!"))
                return
            }
            
            for getResRecord in getResRecords {
                getResRecord.setValue(true, forKey: "deleted")
            }
            
            let modification = CKModifyRecordsOperation(recordsToSave: getResRecords, recordIDsToDelete: nil)
            modification.savePolicy = .changedKeys
            modification.qualityOfService = .userInitiated
            modification.modifyRecordsCompletionBlock = { modResRecords, modResDeleteIDs, modResError in
                guard getResRecords.count == modResRecords?.count, modResError == nil else {
                    error(modResError ?? UnexpectedError.noErrorButNotSuccessful("Unknown CloudKit error!"))
                    return
                }
                
                success()
            }
            
            self.cloud.add(modification)
        }
    }
    
    internal func onLocalChange(changes: RealmCollectionChange<Results<Password>>) {
        switch changes {
        case .update(_, _, let insertions, let modifications):
            // For every item that has to be synced
            for insertion in insertions {
                self.onLocalChange(localResults![insertion])
            }

            // For every item that is syncing, and has to be synced again
            for modification in modifications {
                self.onLocalChange(localResults![modification])
            }
        default:
            break
        }
    }
    
    internal func onLocalChange(_ password: Password) {
        let record = CloudKitPasswordConverter.getRemote(password)
        let passwordReference = ThreadSafeReference(to: password)
        
        let modification = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modification.savePolicy = .changedKeys
        modification.qualityOfService = .userInitiated
        modification.modifyRecordsCompletionBlock = { records, deletedIDs, error in
            if records?.count != 1 {
                log.error(error?.localizedDescription ?? "Unknown CloudKit error!")
            }
            
            autoreleasepool {
                if let realm = RealmHelper.shared.getRealm() {
                    guard let password = realm.resolve(passwordReference) else {
                        return // Password was deleted in the meantime
                    }
                    
                    try! realm.write {
                        password.syncing = false
                        password.synced = records?.count == 1
                        password.deleted = (records?.count != 1) ? false : password.deleted
                        password.syncErrorType = (error == nil) ? nil : Password.SyncErrorTypes.INSERT
                        password.syncErrorDescription = (error == nil) ? nil : error!.localizedDescription
                    }
                }
            }
        }
        
        cloud.add(modification)
    }
    
    internal func subscribeToCloudKitChanges() {
        let subscription = CKQuerySubscription(
            recordType: Password.TABLE,
            predicate: NSPredicate(value: true),
            subscriptionID: CKSubscription.ID(idr(CloudKitPasswordSyncer.self)),
            options: [
                CKQuerySubscription.Options.firesOnRecordCreation,
                CKQuerySubscription.Options.firesOnRecordUpdate
            ]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notificationInfo
        
        cloud.save(subscription) { (subscription, error) in
            guard subscription != nil else {
                log.error(error?.localizedDescription ?? "Unknown CloudKit error!")
                return
            }
        }
    }
    
}
