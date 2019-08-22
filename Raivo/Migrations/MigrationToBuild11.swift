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

class MigrationToBuild11: MigrationProtocol {
    
    static var build: Int = 11
    
    /// This build does not require Realm migrations
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        
    }
    
    /// Run the migrations that are needed to succesfully use this build after an update
    func migrateGeneric() {
        log.verbose("Running migrations")
        
        migrateTouchIDToBiometricInStorage()
    }
    
    /// Run the migrations that are needed to succesfully use this build after an update
    func migrateGeneric(withAccount: SyncerAccount) {

    }
    
    /// Migrate the TouchID key to the Biometric Authentication key
    private func migrateTouchIDToBiometricInStorage() {
        let biometricEnabled = StorageHelper.shared.getTouchIDUnlockEnabled()
        StorageHelper.shared.setBiometricUnlockEnabled(biometricEnabled)
    }
    
}
