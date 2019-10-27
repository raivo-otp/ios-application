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

class MigrationHelper {
    
    private static let initialPreviousBuild = getPreviousBuild()
    
    public static let migrations: [Int: MigrationProtocol] = [
        MigrationToBuild4.build: MigrationToBuild4(),
        MigrationToBuild6.build: MigrationToBuild6(),
        MigrationToBuild9.build: MigrationToBuild9(),
        MigrationToBuild15.build: MigrationToBuild15(),
        MigrationToBuild23.build: MigrationToBuild23()
    ]
    
    static func runPreInitializeMigrations() {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migratePreInitialize()
            }
            
            previous += 1
        }
        
        StorageHelper.shared.setPreviousBuild(AppHelper.build)
    }
    
    static func runGenericMigrations() {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric()
            }
            
            previous += 1
        }
    }
    
    static func runGenericMigrations(with account: SyncerAccount) {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric(with: account)
            }
            
            previous += 1
        }
    }
    
    private static func getPreviousBuild() -> Int {
        if let previousVersion = StorageHelper.shared.getPreviousBuild() {
            return previousVersion
        }
        
        return AppHelper.build
    }
    
}
