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
class MigrationToBuild21: MigrationProtocol {
    
    /// The keys that can be used to get/set values
    private struct Key {
        static let LOCKSCREEN_TIMEOUT = "LockscreenTimeout"
        static let REALM_FILENAME = "RealmFilename"
        static let SYNCHRONIZATION_PROVIDER = "SynchronizationProvider"
        static let SYNCHRONIZATION_ACCOUNT_IDENTIFIER = "SynchronizationProviderAccountIdentifier"
        static let ICONS_EFFECT = "IconsEffect"
        static let PASSCODE_TRIED_AMOUNT = "PasscodeTriedAmount"
        static let PASSCODE_TRIED_TIMESTAMP = "PasscodeTriedTimestamp"
        static let PREVIOUS_BUILD = "PreviousBuild"
        static let TOUCHID_ENABLED = "TouchIDEnabled"
        static let BIOMETRIC_AUTHENTICATION_ENABLED = "BiometricAuthenticationEnabled"
        static let FILE_LOGGING_ENABLED = "FileLoggingEnabled"
    }
    
    /// The build number belonging to this migration.
    static var build: Int = 21
    
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
        
        migrateKeychainSettingsToGlobals()
    }
    
    /// This build does not require generic migrations using the syncer account.
    ///
    /// - Parameter account: The syncer account that can be used for migrating.
    func migrateGeneric(with account: SyncerAccount) {
        log.warning("Running generic migration with syncer account...")
        
        // Not implemented
    }
    
    /// Migrate keychain "Settings" (which can be accessed when the device is unlocked) to "Globals" which are always available.
    private func migrateKeychainSettingsToGlobals() {
        if let value = getLockscreenTimeout() { StorageHelper.shared.setLockscreenTimeout(value) }
        if let value = getRealmFilename() { StorageHelper.shared.setRealmFilename(value) }
        if let value = getSynchronizationProvider() { StorageHelper.shared.setSynchronizationProvider(value) }
        if let value = getSynchronizationAccountIdentifier() { StorageHelper.shared.setSynchronizationAccountIdentifier(value) }
        if let value = getIconsEffect() { StorageHelper.shared.setIconsEffect(value) }
        if let value = getPasscodeTriedAmount() { StorageHelper.shared.setPasscodeTriedAmount(value) }
        if let value = getPasscodeTriedTimestamp() { StorageHelper.shared.setPasscodeTriedTimestamp(value) }
        if let value = getPreviousBuild() { StorageHelper.shared.setPreviousBuild(value) }
        StorageHelper.shared.setBiometricUnlockEnabled(getBiometricUnlockEnabled())
        StorageHelper.shared.setFileLoggingEnabled(getFileLoggingEnabled())
    }
    
    /// Get the lockscreen timeout.
    ///
    /// - Returns: The lockscreen timeout
    private func getLockscreenTimeout() -> TimeInterval? {
        guard let timeout = StorageHelper.shared.settings().string(forKey: Key.LOCKSCREEN_TIMEOUT) else {
            return nil
        }
        
        return TimeInterval(timeout)
    }
    
    /// Get the realm filename.
    ///
    /// - Returns: The realm filename
    public func getRealmFilename() -> String? {
        return StorageHelper.shared.settings().string(forKey: Key.REALM_FILENAME)
    }
    
    /// Get the synchronization provider.
    ///
    /// - Returns: The synchronization provider
    public func getSynchronizationProvider() -> String? {
        return StorageHelper.shared.settings().string(forKey: Key.SYNCHRONIZATION_PROVIDER)
    }
    
    /// Get the synchronization account identifier.
    ///
    /// - Returns: The identifier
    public func getSynchronizationAccountIdentifier() -> String? {
        return StorageHelper.shared.settings().string(forKey: Key.SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
    }
    
    /// Get the icons effect.
    ///
    /// - Returns: The icons effect
    public func getIconsEffect() -> String? {
        return StorageHelper.shared.settings().string(forKey: Key.ICONS_EFFECT)
    }
    
    /// Get the amount of times the user tried to enter the passcode.
    ///
    /// - Returns: The amount of tries
    public func getPasscodeTriedAmount() -> Int? {
        guard let tries = StorageHelper.shared.settings().string(forKey: Key.PASSCODE_TRIED_AMOUNT) else {
            return nil
        }
        
        return Int(tries)
    }
    
    /// Get the timestamp of the last passcode try.
    ///
    /// - Returns: The last time the user tried a passcode
    public func getPasscodeTriedTimestamp() -> TimeInterval? {
        guard let tries = StorageHelper.shared.settings().string(forKey: Key.PASSCODE_TRIED_TIMESTAMP) else {
            return nil
        }
        
        return TimeInterval(tries)
    }
    
    /// Get the previous application build version.
    ///
    /// - Returns: The previous build
    public func getPreviousBuild() -> Int? {
        guard let build = StorageHelper.shared.settings().string(forKey: Key.PREVIOUS_BUILD) else {
            return nil
        }
        
        return Int(build)
    }
   
    /// Check if biometric unlock is currently enabled.
    ///
    /// - Returns: Positive if biometric unlock is enabled
    public func getBiometricUnlockEnabled() -> Bool {
        guard let enabled = StorageHelper.shared.settings().string(forKey: Key.BIOMETRIC_AUTHENTICATION_ENABLED) else {
            return false
        }
        
        return Bool(enabled) ?? false
    }
    
    /// Check if local file logging is enabled.
    ///
    /// - Returns: Positive if local file logging is enabled.
    public func getFileLoggingEnabled() -> Bool {
        guard let enabled = StorageHelper.shared.settings().string(forKey: Key.FILE_LOGGING_ENABLED) else {
            return false
        }
        
        return Bool(enabled) ?? false
    }
    
}
