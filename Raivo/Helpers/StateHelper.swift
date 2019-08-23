//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found 
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import RealmSwift

/// A helper class for managing the state of this app
class StateHelper {
    
    /// The singleton instance for the StateHelper
    public static let shared = StateHelper()
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}

    /// All of the available storyboards within the application
    public struct Storyboard {
        static let LOAD = "Load"
        static let SETUP = "Setup"
        static let AUTH = "Auth"
        static let MAIN = "Main"
        static let ERROR = "Error"
    }
    
    /// The root controllers belonging to certain storyboards
    public struct StoryboardController {
        // Generic controllers
        static let LOAD = "LoadRootController"
        static let SETUP = "SetupRootController"
        static let AUTH = "AuthRootController"
        static let MAIN = "MainRootController"
        
        // Available error controllers
        static let ERROR_SAU = "ErrorSyncerAccountChangedViewController"
        static let ERROR_DNP = "ErrorDowngradeNotPermittedViewController"
    }
    
    /// The states that the application can reside in
    public struct State {
        /// The application must pass the loading state before user interaction is possible
        static let APPLICATION_NOT_LOADED = "APPLICATION_NOT_LOADED"
        
        /// If the application was just downloaded, the local database does not exist
        static let LOCAL_DATABASE_UNKNOWN = "LOCAL_DATABASE_UNKNOWN"
        
        /// If the user e.g. revoked the syncer API key (or if e.g. the iCloud account changed in the background)
        static let SYNCER_ACCOUNT_UNAVAILABLE = "SYNCER_ACCOUNT_UNAVAILABLE"
        
        /// Migration rollbacks can't be done, the application must show an error if the user downgraded the app
        static let DOWNGRADE_NOT_PERMITTED = "DOWNGRADE_NOT_PERMITTED"
        
        /// If the application is fully initialized, but the user needs to enter the pincode
        static let ENCRYPTION_KEY_UNKNOWN = "ENCRYPTION_KEY_UNKNOWN"
        
        /// The user is signed in and all checks were passed
        static let DATABASE_AND_ENCRYPTION_KEY_AVAILABLE = "DATABASE_AND_ENCRYPTION_KEY_AVAILABLE"
    }
    
    /// Calculate and retrieve the current state of the application.
    /// The current state can e.g. represent 'user is not signed in'.
    ///
    /// - Returns: The current state
    public func getCurrentState() -> String {
        guard userDidNotDowngrade() else {
            log.verbose("State: " + State.DOWNGRADE_NOT_PERMITTED)
            return State.DOWNGRADE_NOT_PERMITTED
        }
        
        guard applicationIsLoaded() else {
            log.verbose("State: " + State.APPLICATION_NOT_LOADED)
            return State.APPLICATION_NOT_LOADED
        }
        
        guard localDatabaseExists() else {
            log.verbose("State: " + State.LOCAL_DATABASE_UNKNOWN)
            return State.LOCAL_DATABASE_UNKNOWN
        }
        
        guard syncerAccountIsAvailable() else {
            log.verbose("State: " + State.SYNCER_ACCOUNT_UNAVAILABLE)
            return State.SYNCER_ACCOUNT_UNAVAILABLE
        }
        
        guard encryptionKeyIsKnown() else {
            log.verbose("State: " + State.ENCRYPTION_KEY_UNKNOWN)
            return State.ENCRYPTION_KEY_UNKNOWN
        }

        log.verbose("State: " + State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE)
        return State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE
    }
    
    /// Retrieve the storyboard belonging to the current state of the application.
    ///
    /// - Returns: The current storyboard
    public func getCurrentStoryboard() -> String {
        switch getCurrentState() {
        case State.DOWNGRADE_NOT_PERMITTED:
            return Storyboard.ERROR
        case State.APPLICATION_NOT_LOADED:
            return Storyboard.LOAD
        case State.LOCAL_DATABASE_UNKNOWN:
            return Storyboard.SETUP
        case State.SYNCER_ACCOUNT_UNAVAILABLE:
            return Storyboard.ERROR
        case State.ENCRYPTION_KEY_UNKNOWN:
            return Storyboard.AUTH
        case State.DATABASE_AND_ENCRYPTION_KEY_AVAILABLE:
            return Storyboard.MAIN
        default:
            log.error("Unknown current state.")
            fatalError("Unknown current state.")
        }
    }
    
    /// Retrieve the storyboard controller belonging to current storyboard.
    ///
    /// - Returns: The current storyboard controller name (e.g. `MainRootController`)
    public func getCurrentStoryboardController() -> String {
        switch getCurrentStoryboard() {
        case Storyboard.LOAD:
            return StoryboardController.LOAD
        case Storyboard.SETUP:
            return StoryboardController.SETUP
        case Storyboard.ERROR:
            return getCurrentErrorStoryboardController()
        case Storyboard.AUTH:
            return StoryboardController.AUTH
        case Storyboard.MAIN:
            return StoryboardController.MAIN
        default:
            log.error("Unknown storyboard.")
            fatalError("Unknown storyboard.")
        }
    }
    
    /// Retrieve the storyboard controller belonging to error storyboard.
    ///
    /// - Returns: The current storyboard error controller name (e.g. `ErrorSyncerAccountChangedViewController`)
    public func getCurrentErrorStoryboardController() -> String {
        switch getCurrentState() {
        case State.SYNCER_ACCOUNT_UNAVAILABLE:
            return StoryboardController.ERROR_SAU
        case State.DOWNGRADE_NOT_PERMITTED:
            return StoryboardController.ERROR_DNP
        default:
            log.error("Unknown error storyboard.")
            fatalError("Unknown error storyboard.")
        }
    }
    
    /// Reset the state of the app to `State.LOCAL_DATABASE_UNKNOWN`.
    ///
    /// - Parameter dueToPINCodeChange: Positive if only certain keychain items should be removed.
    /// - Note: The 'dueToPINCodeChange' param can be set to true on e.g. a PIN code change.
    /// - Note: Realm auxiliary files will be deleted
    ///         https://realm.io/docs/swift/latest/#deleting-realm-files
    public func reset(dueToPINCodeChange PINChanged: Bool = false) {
        log.warning("Resetting the state and all data of the app")
        
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        
        try? FileManager.default.removeItem(at: realmURL)
        try? FileManager.default.removeItem(at: realmURL.appendingPathExtension("lock"))
        try? FileManager.default.removeItem(at: realmURL.appendingPathExtension("unlockme"))
        try? FileManager.default.removeItem(at: realmURL.appendingPathExtension("note"))
        try? FileManager.default.removeItem(at: realmURL.appendingPathExtension("management"))
        
        SyncerHelper.shared.clear(dueToPINCodeChange: PINChanged)
        StorageHelper.shared.clear(dueToPINCodeChange: PINChanged)
        
        lock()
    }
    
    /// Remove the encryption key that is in memory and then update the storyboard.
    public func lock() {
        getAppDelegate().updateEncryptionKey(nil)
        getAppDelegate().updateStoryboard()
    }
    
    /// Check if this is the first time that the app runs after being (re)installed.
    ///
    /// - Returns: Positive if app runs for the first time after being (re)installed
    /// - Note:
    ///     This method uses the `UserDefaults` (which are flushed on reinstall) to check wether this is the first run.
    ///     The `Keychain` can't be used since it's persistent even after uninstalling the app.
    ///     https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
    /// - Note:
    ///     Apparently the `UserDefaults` aren't that reliable, as stated in the article "The Mystery of the
    ///     Disappearing NSUserDefaults Keys". Therefore, a file on disk is used as the primary check from now on.
    ///     https://damir.me/the-mystery-of-the-disappearing-nsuserdefaults-keys/
    public func isFirstRun() -> Bool {
        // FileManager method
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let hasRunBeforeFile = documentsDirectory.appendingPathComponent("hasRunBefore.txt")
        
        if fileManager.fileExists(atPath: documentsDirectory.path) {
            return false
        } else {
            log.verbose("Creating hasRunBefore file in filesystem")
            
            fileManager.createFile(
                atPath: hasRunBeforeFile.path,
                contents: "Raivo OTP has ran before".data(using: .utf8),
                attributes: nil
            )
        }
        
        // UserDefaults method
        let userDefaults = UserDefaults.standard
        
        if !userDefaults.bool(forKey: "hasRunBefore") {
            log.verbose("Setting hasRunBefore flag in UserDefaults")
            
            userDefaults.set(true, forKey: "hasRunBefore")
            return true
        } else {
            return false
        }
    }
    
    /// Ensure the user did not downgrade to a lower version of the application.
    ///
    /// - Returns: Positive if the user did not downgrade.
    private func userDidNotDowngrade() -> Bool {
        if let previous = StorageHelper.shared.getPreviousBuild() {
            let downgraded = AppHelper.build < previous
            return !downgraded
        }
        
        return true
    }
    
    /// Checks if the application passed the loading storyboard.
    ///
    /// - Returns: Positive if it passed the loading storyboard.
    private func applicationIsLoaded() -> Bool {
        return getAppDelegate().applicationIsLoaded
    }
    
    /// Checks if a local realm database exists.
    ///
    /// - Returns: Positive if a local ream database exists.
    private func localDatabaseExists() -> Bool {
        return RealmHelper.fileURLExists()
    }
    
    /// Checks if the syncer account is available and if e.g. the API key hasn't been revoked.
    /// This makes sure we can still save data to our synchronization provider.
    ///
    /// - Returns: Positive if synchronization account is available.
    private func syncerAccountIsAvailable() -> Bool {
        let currentSAI = getAppDelegate().syncerAccountIdentifier
        let storedSAI = StorageHelper.shared.getSynchronizationAccountIdentifier()
        
        return currentSAI == storedSAI
    }

    /// Checks if the user entered his/her PIN code and that therefore the encryption key is known.
    ///
    /// - Returns: Positive if encryption key is known.
    private func encryptionKeyIsKnown() -> Bool {
        return getAppDelegate().getEncryptionKey() != nil
    }
    
}
