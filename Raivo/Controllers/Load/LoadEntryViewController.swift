//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit
import SwiftyBeaver
import SDWebImage

class LoadEntryViewController: UIViewController {
    
    private var errorMessage: String?
    
    override func viewDidLoad() {
        
        // Run migrations prior the the app initialization.
        do { try MigrationHelper.shared.runPreInitializeMigrations() } catch {
            return errorMessage = "Could not run pre-initialization migrations"
        }

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
            
            do { try StorageHelper.shared.clear() } catch {
                return errorMessage = "Could not clear storage during first run of the app"
            }
        }
        
        // Run all migrations except Realm migrations
        do { try MigrationHelper.shared.runGenericMigrations() } catch {
            return errorMessage = "Could not run generic migrations"
        }

        // Preload the synchronization information
        SyncerHelper.shared.getSyncer().getAccount(success: { (account, syncerID) in
            DispatchQueue.main.async {
                log.verbose("Got syncer account successfully")
                MigrationHelper.shared.runGenericMigrations(with: account)
                
                getAppDelegate().syncerAccountIdentifier = account.identifier
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard()
            }
        }, error: { (error, syncerID) in
            DispatchQueue.main.async {
                log.verbose("Error while getting syncer account: \(error)")
                getAppDelegate().syncerAccountIdentifier = nil
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard()
            }
        })
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let errorMessage = errorMessage {
            log.error("An error occurred during entry loading: \(errorMessage)")
            BannerHelper.shared.error("Error", errorMessage)
        }
    }
    
}
