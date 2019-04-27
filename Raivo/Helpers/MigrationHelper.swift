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
    
    private static let migrations: [Int: MigrationProtocol] = [
        Migration4.build: Migration4()
    ]
    
    static func runGenericMigrations() {
        var previous = getPreviousBuild()
        
        while previous <= AppHelper.build {
            if let migration = migrations[previous + 1] {
                migration.migrateGeneric()
            }
            
            previous += 1
        }
        
        StorageHelper.settings().set(string: String(AppHelper.build), forKey: StorageHelper.KEY_PREVIOUS_BUILD)
    }
    
    private static func getPreviousBuild() -> Int {
        if let previousVersion = StorageHelper.settings().string(forKey: StorageHelper.KEY_PREVIOUS_BUILD) {
            return Int(previousVersion)!
        }
        
        // This could be a newly installed app, but lets first check if the previous version could be a version that didn't have this update mechanism yet.
        if (migrations[4]! as! Migration4).hasToMigrate() {
            return AppHelper.build - 1
        }
        
        return AppHelper.build
    }
    
}
