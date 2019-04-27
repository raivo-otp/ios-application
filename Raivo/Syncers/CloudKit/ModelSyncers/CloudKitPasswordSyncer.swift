//
//  CloudKitPasswordSyncer.swift
//  Raivo
//
//  Created by Tijme Gommers on 13/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift
import CloudKit

class CloudKitPasswordSyncer: BaseClass, CloudKitModelSyncerProtocol {

    private let cloud = CKContainer.default().privateCloudDatabase
    
    private var localNotifications: NotificationToken?
    
    private var localResults: Results<Password>?
    
    deinit {
        disable()
    }
    
    func enable() {
        disable()
        
        let realm = try! Realm()
        localResults = realm.objects(Password.self).filter("syncing == 1")
        localNotifications = localResults!.observe(onLocalChange)
        
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
                log.error(error ?? "Unknown CloudKit error!")
                return
            }
            
            let realm = try! Realm()
            for record in records {
                let local = CloudKitPasswordConverter.getLocal(record)
                
                guard local == nil || (local?.synced == true && local?.syncing == false) else {
                    // Do not save passwords that still have to be synced
                    self.onLocalChange(local!)
                    continue
                }
                
                let copy = CloudKitPasswordConverter.getLocalCopy(record, syncedCorrectly: true)
                
                try! realm.write {
                    realm.add(copy, update: true)
                }
            }
        }
    }
    
    func notify(_ notification: CKQueryNotification?) {
        guard notification?.subscriptionID == CloudKitPasswordSyncer.UNIQUE_ID else {
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
                error(getResError ?? UnexpectedError("Unknown CloudKit error!"))
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
                    error(modResError ?? UnexpectedError("Unknown CloudKit error!"))
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
                log.error(error ?? "Unknown CloudKit error!")
            }
            
            let realm = try! Realm()
            
            guard let password = realm.resolve(passwordReference) else {
                return // Password was deleted in the meantime
            }
            
            try! realm.write {
                password.syncing = false
                password.synced = records?.count == 1
                password.syncErrorType = (error == nil) ? nil : Password.SyncErrorTypes.INSERT
                password.syncErrorDescription = (error == nil) ? nil : error!.localizedDescription
            }
        }
        
        cloud.add(modification)
    }
    
    internal func subscribeToCloudKitChanges() {
        let subscription = CKQuerySubscription(
            recordType: Password.TABLE,
            predicate: NSPredicate(value: true),
            subscriptionID: CKSubscription.ID(CloudKitPasswordSyncer.UNIQUE_ID),
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
                log.error(error ?? "Unknown CloudKit error!")
                return
            }
        }
    }
    
}
