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
import UIKit
import SwiftyBeaver
import SDWebImage

class LoadEntryViewController: UIViewController {
    
    override func viewDidLoad() {
        // Trigger Realm to use the current encryption key
        getAppDelegate().updateEncryptionKey(getAppDelegate().getEncryptionKey())

        // Initialize debug logging (if applicable)
        let console = ConsoleDestination()
        console.minLevel = AppHelper.logLevel
        log.addDestination(console)
        
        // Initialize SDImage configurations
        SDImageCache.shared.config.maxDiskAge = TimeInterval(60 * 60 * 24 * 365 * 4)
        
        // If this is the first run of the app, flush the keychain.
        // It could be a reinstall of the app (reinstalls don't flush the keychain).
        // This means that e.g. encryption keys could still be available in the keychain.
        // https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
        if StateHelper.shared.isFirstRun() {
            StorageHelper.shared.clear()
        }
        
        // Run all migrations except Realm migrations
        MigrationHelper.runGenericMigrations()

        // Preload the synchronization information
        SyncerHelper.shared.getSyncer().getAccount(success: { (account, syncerID) in
            DispatchQueue.main.async {
                MigrationHelper.runGenericMigrations(withAccount: account)
                
                getAppDelegate().syncerAccountIdentifier = account.identifier
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard(.transitionCrossDissolve)
            }
        }, error: { (error, syncerID) in
            DispatchQueue.main.async {
                getAppDelegate().syncerAccountIdentifier = nil
                getAppDelegate().applicationIsLoaded = true
                getAppDelegate().updateStoryboard(.transitionCrossDissolve)
            }
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                view.backgroundColor = UIColor.getBackgroundOpaque(true)
            default:
                view.backgroundColor = UIColor.getBackgroundOpaque()
            }
        }
    }
    
}
