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

import RealmSwift

/// A protocol for data and Realm migrations.
protocol MigrationProtocol {
    
    /// A migration must have a build number that it targets.
    static var build: Int { get }
    
    /// A function for running realm migrations.
    func migrateRealm(_ migration: Migration) -> Void
    
    /// A function for running migrations before initializing the application.
    func migratePreInitialize() -> Void
    
    /// A function for running generic migrations before initializing the syncers.
    func migrateGeneric() -> Void
    
    /// A function for running migrations that require synchronization provider access.
    func migrateGeneric(with account: SyncerAccount) -> Void
    
}
