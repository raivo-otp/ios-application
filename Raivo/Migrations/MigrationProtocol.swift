//
//  MigrationProtocol.swift
//  Raivo
//
//  Created by Tijme Gommers on 27/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import RealmSwift

protocol MigrationProtocol {
    
    static var build: Int { get }
    
    func migrateRealm(_ migration: Migration) -> Void
    
    func migrateGeneric() -> Void
    
    func migrateGeneric(withAccount: SyncerAccount) -> Void
    
}
