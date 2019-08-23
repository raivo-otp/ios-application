//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import RealmSwift

/// A protocol for data and Realm migrations.
protocol MigrationProtocol {
    
    /// A migration must have a build number that it targets.
    static var build: Int { get }
    
    /// A function for running realm migrations.
    func migrateRealm(_ migration: Migration) -> Void
    
    /// A function for running generic migrations before initializing the syncers.
    func migrateGeneric() -> Void
    
    /// A function for running migrations that require synchronization provider access.
    func migrateGeneric(with account: SyncerAccount) -> Void
    
}
