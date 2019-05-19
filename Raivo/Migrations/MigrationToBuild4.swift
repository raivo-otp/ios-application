//
//  MigrationToBuild4.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainSwift

class MigrationToBuild4: MigrationProtocol {

    static var build: Int = 4
    
    /// This build does not require Realm migrations
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        
    }
    
    /// This build does not require generic migrations
    func migrateGeneric() {
        
    }
    
    /// This build does not require generic migrations
    func migrateGeneric(withAccount: SyncerAccount) {
        
    }
    
}
