//
//  StateHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/01/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class StateHelper: BaseClass {
    
    public struct Storyboard {
        static let SETUP = "Setup"
        static let AUTH = "Auth"
        static let MAIN = "Main"
    }
    
    public struct StoryboardController {
        static let SETUP = "SetupRootController"
        static let AUTH = "AuthRootController"
        static let MAIN = "MainRootController"
    }
    
    public struct State {
        static let DATABASE_UNKNOWN = "DATABASE_UNKNOWN"
        static let ENCRYPTION_KEY_UNKNOWN = "ENCRYPTION_KEY_UNKNOWN"
        static let DATABASE_AND_ENCRYPTION_KEY_AVAILABLE = "DATABASE_AND_ENCRYPTION_KEY_AVAILABLE"
    }
    
    public static func getCurrentState() -> String {
        guard databaseIsKnown() else {
            return State.DATABASE_UNKNOWN
        }
        
        guard encryptionKeyIsKnown() else {
            return State.ENCRYPTION_KEY_UNKNOWN
        }
   
        return State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE
    }
    
    public static func getCurrentStoryboard() -> String {
        switch getCurrentState() {
        case State.DATABASE_UNKNOWN:
            return Storyboard.SETUP
        case State.ENCRYPTION_KEY_UNKNOWN:
            return Storyboard.AUTH
        case State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE:
            return Storyboard.MAIN
        default:
            fatalError("Unknown current state.")
        }
    }
    
    public static func getCurrentStoryboardController() -> String {
        switch getCurrentStoryboard() {
        case Storyboard.SETUP:
            return StoryboardController.SETUP
        case Storyboard.AUTH:
            return StoryboardController.AUTH
        case Storyboard.MAIN:
            return StoryboardController.MAIN
        default:
            fatalError("Unknown storyboard.")
        }
    }
    
    public static func reset(clearKeychain: Bool = true) {
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        getAppDelagate().updateEncryptionKey(nil)
        
        SyncerHelper.clear()
        
        if clearKeychain {
            StorageHelper.clear()
        }
    }
    
    /// Remove the encryption key that is in memory and then update the storyboard
    public static func lock() {
        getAppDelagate().updateEncryptionKey(nil)
        getAppDelagate().updateStoryboard()
    }
    
    /// Check if this is the first time that the app runs after being (re)installed
    ///
    /// - Returns: `true` if app runs for the first time after being (re)installed
    ///
    /// - Note: This method uses the `UserDefaults` (which are flushed on reinstall) to check wether nthis is the first run
    /// - Note: The `Keychain` can't be used since it's persistent even after uninstalling the app
    /// https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
    public static func isFirstRun() -> Bool {
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: "hasRunBefore") {
            userDefaults.set(true, forKey: "hasRunBefore")
            return true
        } else {
            return false
        }
    }
    
    private static func databaseIsKnown() -> Bool {
        return RealmHelper.fileURLExists()
    }
    
    private static func encryptionKeyIsKnown() -> Bool {
        return getAppDelagate().getEncryptionKey() != nil
    }
    
}
