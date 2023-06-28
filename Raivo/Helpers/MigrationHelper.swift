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
import Valet

/// A helper class for managing database, configuration and code migrations
class MigrationHelper {
    
    /// The singleton instance for the MigrationHelper
    public static let shared = MigrationHelper()
    
    /// The pervious application runtime build version
    private var initialPreviousBuild: Int?
    
    /// All vailable migration builds and the corresponding migration classes
    public let migrations: [Int: MigrationProtocol] = [
        MigrationToBuild60.build: MigrationToBuild60()
    ]
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Start migrations that have to run before performing any app functions (first thing first in the application delegate)
    ///
    /// - Note: Only required when e.g. migrating (keychain) items that are referenced before initialization of the app
    /// - Note: This migration function runs all migrations, always, even for previous builds. The migrations should include conditionals for when to be executed.
    public func runPreBootMigrations() {
        var previous = 0
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migratePreBoot()
            }
            
            previous += 1
        }
    }
    
    /// Start migrations that have to run before initialization of the app
    ///
    /// - Note: This should usually be the preferred migration method
    public func runPreInitializeMigrations() throws {
        var previous = getPreviousBuild()
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                try migration.migratePreInitialize()
            }
            
            previous += 1
        }
        
        try StorageHelper.shared.setPreviousBuild(AppHelper.build)
        try StorageHelper.shared.setPreviousMajorVersion(AppHelper.versionMajor)
    }
    
    /// Start migrations that have to run during initialization of the app (before getting the current syncer account)
    public func runGenericMigrations() throws {
        var previous = getPreviousBuild()
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                try migration.migrateGeneric()
            }
            
            previous += 1
        }
    }
    
    /// Start migrations that have to run during initialization of the app (after getting the current syncer account)
    public func runGenericMigrations(with account: SyncerAccount) {
        var previous = getPreviousBuild()
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric(with: account)
            }
            
            previous += 1
        }
    }
    
    /// Get the build version of the previous runtime (e.g. before an update)
    ///
    /// - Returns: The build version of the previous runtime
    private func getPreviousBuild() -> Int {
        if let initialPreviousBuild = initialPreviousBuild {
            return initialPreviousBuild
        }
        
        if let previousVersion = StorageHelper.shared.getPreviousBuild() {
            initialPreviousBuild = previousVersion
        } else {
            initialPreviousBuild = AppHelper.build
        }
        
        return getPreviousBuild()
    }
    
}
