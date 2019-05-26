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
    
    /// This build does not require generic migrations
    func migrateGeneric(withAccount: SyncerAccount) {
        
    }
    
}
