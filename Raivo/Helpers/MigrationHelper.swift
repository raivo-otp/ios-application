//
//  MigrationHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 27/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Valet

class MigrationHelper {
    
    public static let migrations: [Int: MigrationProtocol] = [
        MigrationToBuild4.build: MigrationToBuild4(),
        MigrationToBuild6.build: MigrationToBuild6()
    ]
    
    static func runGenericMigrations() {
        var previous = getPreviousBuild()
        
        while previous <= AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric()
            }
            
            previous += 1
        }
        
        StorageHelper.setPreviousBuild(AppHelper.build)
    }
    
    private static func getPreviousBuild() -> Int {
        if let previousVersion = StorageHelper.getPreviousBuild() {
            return previousVersion
        }
        
        return AppHelper.build
    }
    
}
