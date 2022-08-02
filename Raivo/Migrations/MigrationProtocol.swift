//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import RealmSwift

/// A protocol for data and Realm migrations.
protocol MigrationProtocol {
    
    /// A migration must have a build number that it targets.
    static var build: Int { get }
    
    /// A function for running realm migrations.
    func migrateRealm(_ migration: Migration) -> Void
    
    /// A function for running migrations before performing any app functions (first thing first in the application delegate)
    ///
    /// - Note: Only required when e.g. migrating (keychain) items that are referenced before initialization of the app
    /// - Note: This method always runs, for all migrations, always, even for previous builds. The migrations should include conditionals for when to be executed.
    func migratePreBoot() -> Void
    
    /// A function for running migrations before initializing the application.
    ///
    /// - Throws: Migration exceptions on fail
    func migratePreInitialize() throws -> Void
    
    /// A function for running generic migrations before initializing the syncers.
    ///
    /// - Throws: Migration exceptions on fail
    func migrateGeneric() throws -> Void
    
    /// A function for running migrations that require synchronization provider access.
    func migrateGeneric(with account: SyncerAccount) -> Void
    
}
