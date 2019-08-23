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
import Valet

class MigrationHelper {
    
    private static let initialPreviousBuild = getPreviousBuild()
    
    public static let migrations: [Int: MigrationProtocol] = [
        MigrationToBuild4.build: MigrationToBuild4(),
        MigrationToBuild6.build: MigrationToBuild6(),
        MigrationToBuild9.build: MigrationToBuild9(),
        MigrationToBuild11.build: MigrationToBuild11()
    ]
    
    static func runGenericMigrations() {
        var previous = initialPreviousBuild
        
        while previous < AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric()
            }
            
            previous += 1
        }
        
        StorageHelper.shared.setPreviousBuild(AppHelper.build)
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
