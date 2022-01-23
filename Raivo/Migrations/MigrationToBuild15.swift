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
class MigrationToBuild15: MigrationProtocol {
    
    /// The build number belonging to this migration.
    static var build: Int = 15
    
    /// Run Realm migrations to make data compatible with this build.
    ///
    /// - Parameter migration: The Realm migration containing the old and new entities
    func migrateRealm(_ migration: Migration) {
        log.warning("Running Realm migration...")
        
        // Not implemented
    }
    
    /// Run migrations to make data compatible with this build (before app initialization).
    func migratePreInitialize() {
        log.warning("Running pre init migration...")
        
        migratePincodeToPasscode()
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
    
    /// Migrate "Pincode" to "Passcode" in the keychain.
    private func migratePincodeToPasscode() {
        if let triesString = try? StorageHelper.shared.settings().string(forKey: "PincodeTriedAmount") {
            if let tries = Int(triesString) {
                StorageHelper.shared.setPasscodeTriedAmount(tries)
            }
        }
        
        if let timestampString = try? StorageHelper.shared.settings().string(forKey: "PincodeTriedTimestamp") {
            if let timestamp = TimeInterval(timestampString) {
                StorageHelper.shared.setPasscodeTriedTimestamp(timestamp)
            }
        }
    }
    
}
