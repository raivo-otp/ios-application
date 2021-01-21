//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit
import SwiftyBeaver
import SDWebImage

class LoadEntryViewController: UIViewController {
    
    override func viewDidLoad() {
        
        // Run migrations prior the the app initialization.
        MigrationHelper.shared.runPreInitializeMigrations()

        // Initialize console logging (in debug builds)
        if AppHelper.compilation == AppHelper.Compilation.debug {
            initializeConsoleLogging()
        }
        
        // Initialize file logging (if logging is enabled)
        if StorageHelper.shared.getFileLoggingEnabled() {
            initializeFileLogging()
        }
        
        log.verbose("Loading Raivo OTP")
        
        // Trigger Realm to use the current encryption key
        getAppDelegate().updateEncryptionKey(getAppDelegate().getEncryptionKey())
        
        // Initialize SDImage configurations
        SDImageCache.shared.config.maxDiskAge = TimeInterval(60 * 60 * 24 * 365 * 4)
        
        // If this is the first run of the app, flush the keychain.
        // It could be a reinstall of the app (reinstalls don't flush the keychain).
        // This means that e.g. encryption keys could still be available in the keychain.
        // https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
        if StateHelper.shared.isFirstRun() {
            log.verbose("This is the first run of the app")
            StorageHelper.shared.clear()
        }
        
        // Run all migrations except Realm migrations
        MigrationHelper.shared.runGenericMigrations()

        // Preload the synchronization information
        SyncerHelper.shared.getSyncer().getAccount(success: { (account, syncerID) in
            DispatchQueue.main.async {
                log.verbose("Got syncer account succesfully")
                MigrationHelper.shared.runGenericMigrations(with: account)
                
                getAppDelegate().syncerAccountIdentifier = account.identifier
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard(.transitionCrossDissolve)
            }
        }, error: { (error, syncerID) in
            DispatchQueue.main.async {
                log.verbose("Error while getting syncer account")
                getAppDelegate().syncerAccountIdentifier = nil
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard(.transitionCrossDissolve)
            }
        })
    }
    
}
