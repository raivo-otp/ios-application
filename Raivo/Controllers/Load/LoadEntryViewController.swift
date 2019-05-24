//
//  LoadEntryViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 19/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import SwiftyBeaver
import SDWebImage
import SDWebImageSVGCoder

class LoadEntryViewController: UIViewController {
    
    override func viewDidLoad() {
        // Trigger Realm to use the current encryption key
        getAppDelagate().updateEncryptionKey(getAppDelagate().getEncryptionKey())

        // Initialize debug logging (if applicable)
        let console = ConsoleDestination()
        log.addDestination(console)
        
        // Initialize SDImage configurations
        SDImageCache.shared.config.maxDiskAge = TimeInterval(60 * 60 * 24 * 365 * 4)
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        
        // If this is the first run of the app, flush the keychain
        // It could be a reinstall of the app (reinstalls don't flush the keychain)
        // https://stackoverflow.com/questions/4747404/delete-keychain-items-when-an-app-is-uninstalled
        if StateHelper.isFirstRun() {
            StorageHelper.clear()
        }
        
        // Run all migrations except Realm migrations
        MigrationHelper.runGenericMigrations()

        // Preload the synchronization information
        SyncerHelper.getSyncer().getAccount(success: { (account, syncerID) in
            DispatchQueue.main.async {
                MigrationHelper.runGenericMigrations(withAccount: account)
                
                self.getAppDelagate().syncerAccountIdentifier = account.identifier
                self.getAppDelagate().applicationIsLoaded = true
                self.getAppDelagate().updateStoryboard(.transitionCrossDissolve)
            }
        }, error: { (error, syncerID) in
            DispatchQueue.main.async {
                self.getAppDelagate().syncerAccountIdentifier = nil
                self.getAppDelagate().applicationIsLoaded = true
                self.getAppDelagate().updateStoryboard(.transitionCrossDissolve)
            }
        })
    }
    
}
