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

/// A class for migrating and rolling back changes for the corresponding build.
class MigrationToBuild4: MigrationProtocol {

    /// The build number belonging to this migration.
    static var build: Int = 4
    
    /// Run Realm migrations to make data compatible with this build.
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        log.warning("Running Realm migration...")
        
        // Not implemented
    }
    
    /// Run generic migrations to make data compatible with this build.
    func migrateGeneric() {
        log.warning("Running generic migration...")
        
        // Not implemented
    }
    
    /// This build does not require generic migrations using the syncer account.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    func migrateGeneric(with account: SyncerAccount) {
        log.warning("Running generic migration with syncer account...")
        
        // Not implemented
    }

}
