//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import Valet

/// A helper class for managing database, configuration and code migrations
class MigrationHelper {
    
    /// The singleton instance for the MigrationHelper
    public static let shared = MigrationHelper()
    
    /// The pervious application runtime build version
    private let initialPreviousBuild = getPreviousBuild()
    
    /// All vailable migration builds and the corresponding migration classes
    public let migrations: [Int: MigrationProtocol] = [
        MigrationToBuild4.build: MigrationToBuild4(),
        MigrationToBuild6.build: MigrationToBuild6(),
        MigrationToBuild9.build: MigrationToBuild9(),
        MigrationToBuild15.build: MigrationToBuild15(),
        MigrationToBuild23.build: MigrationToBuild23()
    ]
    
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Start migrations that have to run before initialization of the app
    public func runPreInitializeMigrations() {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migratePreInitialize()
            }
            
            previous += 1
        }
        
        StorageHelper.shared.setPreviousBuild(AppHelper.build)
    }
    
    /// Start migrations that have to run during initialization of the app (before getting the current syncer account)
    public func runGenericMigrations() {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric()
            }
            
            previous += 1
        }
    }
    
    /// Start migrations that have to run during initialization of the app (after getting the current syncer account)
    public func runGenericMigrations(with account: SyncerAccount) {
        var previous = initialPreviousBuild
        
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
        if let previousVersion = StorageHelper.shared.getPreviousBuild() {
            return previousVersion
        }
        
        return AppHelper.build
    }
    
}
