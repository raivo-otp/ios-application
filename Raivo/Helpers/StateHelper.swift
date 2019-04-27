//
//  StateHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class StateHelper {
    
    public struct States {
        static let DATABASE_UNKNOWN = "DATABASE_UNKNOWN"
        static let ENCRYPTION_KEY_UNKNOWN = "ENCRYPTION_KEY_UNKNOWN"
        static let DATABASE_AND_ENCRYPTION_KEY_AVAILABLE = "DATABASE_AND_ENCRYPTION_KEY_AVAILABLE"
    }
    
    public static func getCurrentState() -> String {
        if !self.isDatabaseKnown() {
            return States.DATABASE_UNKNOWN
        } else if !self.isEncryptionKeyKnown() {
            return States.ENCRYPTION_KEY_UNKNOWN
        } else {
            return States.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE
        }
    }
    
    public static func reset(clearKeychain: Bool = true) {
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        getAppDelagate().encryptionKey = nil
        
        SyncerHelper.clear()
        
        if clearKeychain {
            KeychainHelper.clear()
        }
    }
    
    public static func lock() {
        getAppDelagate().encryptionKey = nil
    }
    
    public static func isFirstRun() -> Bool {
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: "hasRunBefore") {
            userDefaults.set(true, forKey: "hasRunBefore")
            return true
        } else {
            return false
        }
    }
    
    private static func isDatabaseKnown() -> Bool {
        return RealmHelper.fileURLExists()
    }
    
    private static func isEncryptionKeyKnown() -> Bool {
        return getAppDelagate().encryptionKey != nil
    }
    
    private static func getAppDelagate() -> AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
}
