//
//  MigrationToBuild6.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import RealmSwift

class MigrationToBuild6: MigrationProtocol {
    
    static var build: Int = 6
    
    /// This build does not require Realm migrations
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        
    }
    
    /// This build does not require generic migrations
    func migrateGeneric() {
        
    }
    
}
