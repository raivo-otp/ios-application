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

/// An object used during the app setup. It remembers all options that the user chose.
class SetupStateObject {
    
    /// The ID of the selected synchronization provider
    var syncerID: String? = nil
    
    /// The user account belonging to the synchronization provider
    var account: SyncerAccount? = nil
    
    /// The challenge belonging to the synchronization provider
    var challenge: SyncerChallenge? = nil
    
    /// The encryption password
    var password: String? = nil
    
    /// Check if a challenge is available.
    ///
    /// - Returns: Positive if user is recovering data.
    public func recoveryMode() -> Bool {
        return challenge?.challenge != nil
    }
    
}
