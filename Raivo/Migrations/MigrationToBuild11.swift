//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import RealmSwift

/// A class for migrating and rolling back changes for the corresponding build.
class MigrationToBuild11: MigrationProtocol {

    /// The build number belonging to this migration.
    static var build: Int = 11
    
    /// Run Realm migrations to make data compatible with this build.
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        log.warning("Running Realm migration...")
        
        // Not implemented
    }
    
    /// A migration function that is always called, for all builds, on every startup.
    ///
    /// - Note: Only required when e.g. migrating (keychain) items that are referenced before initialization of the app
    /// - Note: This migration function should include its own conditionals for when to be executed.
    func migratePreBoot() {
        // Not implemented
    }
    
    /// Run migrations to make data compatible with this build (before app initialization).
    func migratePreInitialize() {
        log.warning("Running pre init migration...")
        
        // Not implemented
    }
    
    /// Run generic migrations to make data compatible with this build.
    func migrateGeneric() {
        log.warning("Running generic migration...")
        
        migrateTouchIDToBiometricInStorage()
    }
    
    /// This build does not require generic migrations using the syncer account.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    func migrateGeneric(with account: SyncerAccount) {
        log.warning("Running generic migration with syncer account...")
        
        // Not implemented
    }
    
    /// Migrate the TouchID key to the Biometric Authentication key
    private func migrateTouchIDToBiometricInStorage() {
        let biometricEnabled = StorageHelper.shared.getTouchIDUnlockEnabled()
        StorageHelper.shared.setBiometricUnlockEnabled(biometricEnabled)
    }
    
}
