//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import Foundation
import LocalAuthentication
import Valet

/// A helper class for the keychain and Secure Enclave
class StorageHelper {
    
    /// The keys that can be used to get/set values
    public struct Key {
        static let PASSWORD = "EncryptionPassword"
        static let LOCKSCREEN_TIMEOUT = "LockscreenTimeout"
        static let REALM_FILENAME = "RealmFilename"
        static let SYNCHRONIZATION_PROVIDER = "SynchronizationProvider"
        static let SYNCHRONIZATION_ACCOUNT_IDENTIFIER = "SynchronizationProviderAccountIdentifier"
        static let ICONS_EFFECT = "IconsEffect"
        static let PASSCODE_TRIED_AMOUNT = "PasscodeTriedAmount"
        static let PASSCODE_TRIED_TIMESTAMP = "PasscodeTriedTimestamp"
        static let PREVIOUS_BUILD = "PreviousBuild"
        static let ENCRYPTION_KEY = "EncryptionKey"
        static let TOUCHID_ENABLED = "TouchIDEnabled"
        static let BIOMETRIC_AUTHENTICATION_ENABLED = "BiometricAuthenticationEnabled"
        static let PREVIOUS_PASSWORD_ENABLED = "PreviousPasswordEnabled"
        static let FILE_LOGGING_ENABLED = "FileLoggingEnabled"
    }
    
    /// The singleton instance for the StorageHelper
    public static let shared = StorageHelper()
   
    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}
    
    /// Get a `Valet` that enables you to store key/value pairs in the keychain (without any protection).
    ///
    /// - Returns: The `Valet` settings instance
    public func globals() -> Valet {
        return Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .afterFirstUnlock)
    }
    
    /// Get a `Valet` that enables you to store key/value pairs in the keychain (outside of Secure Encalve).
    ///
    /// - Returns: The `Valet` settings instance
    public func settings() -> Valet {
        return Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .whenUnlocked)
    }
    
    /// Get a `SecureEnclaveValet` that enables you to store key/value pairs in Secure Encalve.
    ///
    /// - Returns: The `SecureEnclaveValet` secrets instance
    public func secrets() -> SecureEnclaveValet {
        return SecureEnclaveValet.valet(with: Identifier(nonEmpty: "secrets")!, accessControl: .userPresence)
    }
    
    /// Clear all of the settings and secrets so they can be initialized again in a later stage.
    ///
    /// - Parameter dueToPasscodeChange: Positive if only certain keychain items should be removed.
    /// - Returns: Positive on success
    /// - Throws: Valet/Keychain exceptions on fail
    /// - Note The `dueToPasscodeChange` parameter can be set to true on e.g. a passcode change.
    public func clear(dueToPasscodeChange: Bool = false) throws {
        guard !dueToPasscodeChange else { return }

        log.warning("Removing all keychain and secure enclave entries")
        
        try globals().removeAllObjects()
        try settings().removeAllObjects()
        try secrets().removeAllObjects()
        
        // Try to delete literally all items in the keychain, available to the app
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
    
    /// Check if the user can access secrets (some sort of biometric unlock should be available)
    ///
    /// - Returns: Positive if the secrets can be accessed in theory
    public func canAccessSecrets() -> Bool {
        return BiometricHelper.shared.biometricsAvailable()
    }
    
    /// Set the password part of the encryption key.
    ///
    /// - Parameter password: The new password
    /// - Throws: Valet/Keychain exceptions on fail
    public func setEncryptionPassword(_ password: String) throws {
        log.verbose("Setting encryption password")
        try settings().setString(password, forKey: Key.PASSWORD)
    }
    
    /// Get the password part of the encryption key.
    ///
    /// - Returns: The stored password
    public func getEncryptionPassword() -> String? {
        return try? settings().string(forKey: Key.PASSWORD)
    }
    
    /// Set the lockscreen timeout.
    ///
    /// - Parameter seconds: The new lockscreen timeout
    /// - Throws: Valet/Keychain exceptions on fail
    public func setLockscreenTimeout(_ seconds: TimeInterval) throws {
        log.verbose("Setting lockscreen timeout")
        try globals().setString(String(seconds), forKey: Key.LOCKSCREEN_TIMEOUT)
    }
    
    /// Get the lockscreen timeout.
    ///
    /// - Returns: The lockscreen timeout
    public func getLockscreenTimeout() -> TimeInterval? {
        guard let timeout = try? globals().string(forKey: Key.LOCKSCREEN_TIMEOUT) else {
            return nil
        }
        
        return TimeInterval(timeout)
    }
    
    /// Set the realm (sqlite) filename (not the absolute path).
    ///
    /// - Parameter filename: The new filename
    /// - Throws: Valet/Keychain exceptions on fail
    public func setRealmFilename(_ filename: String) throws {
        log.verbose("Setting realm filename")
        try globals().setString(filename, forKey: Key.REALM_FILENAME)
    }
    
    /// Get the realm filename.
    ///
    /// - Returns: The realm filename
    public func getRealmFilename() -> String? {
        return try? globals().string(forKey: Key.REALM_FILENAME)
    }
    
    /// Set the synchronization provider.
    ///
    /// - Parameter provider: The unique ID of the synchronization provider
    /// - Throws: Valet/Keychain exceptions on fail
    public func setSynchronizationProvider(_ provider: String) throws {
        log.verbose("Setting synchronization provider")
        try globals().setString(provider, forKey: Key.SYNCHRONIZATION_PROVIDER)
    }
    
    /// Get the synchronization provider.
    ///
    /// - Returns: The synchronization provider
    public func getSynchronizationProvider() -> String? {
        return try? globals().string(forKey: Key.SYNCHRONIZATION_PROVIDER)
    }
    
    /// Set the synchronization account identifier.
    ///
    /// - Parameter accountIdentifier: The identifier
    /// - Throws: Valet/Keychain exceptions on fail
    public func setSynchronizationAccountIdentifier(_ accountIdentifier: String?) throws {
        log.verbose("Setting synchronization account identifier")
        
        if let accountIdentifier = accountIdentifier {
            try globals().setString(accountIdentifier, forKey: Key.SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
        } else {
            try globals().removeObject(forKey: Key.SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
        }
    }
    
    /// Get the synchronization account identifier.
    ///
    /// - Returns: The identifier
    public func getSynchronizationAccountIdentifier() -> String? {
        return try? globals().string(forKey: Key.SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
    }
    
    /// Set the icons effect.
    ///
    /// - Parameter effect: The icons effect
    /// - Throws: Valet/Keychain exceptions on fail
    public func setIconsEffect(_ effect: String) throws {
        log.verbose("Setting icons effect")
        try globals().setString(effect, forKey: Key.ICONS_EFFECT)
    }
    
    /// Get the icons effect.
    ///
    /// - Returns: The icons effect
    public func getIconsEffect() -> String? {
        return try? globals().string(forKey: Key.ICONS_EFFECT)
    }
    
    /// Set the amount of times the user entered the passcode.
    ///
    /// - Parameter tries: The amount of tries
    /// - Throws: Valet/Keychain exceptions on fail
    public func setPasscodeTriedAmount(_ tries: Int) throws {
        log.verbose("Setting passcode tried amount")
        try globals().setString(String(tries), forKey: Key.PASSCODE_TRIED_AMOUNT)
    }
    
    /// Get the amount of times the user tried to enter the passcode.
    ///
    /// - Returns: The amount of tries
    public func getPasscodeTriedAmount() -> Int? {
        guard let tries = try? globals().string(forKey: Key.PASSCODE_TRIED_AMOUNT) else {
            return nil
        }
        
        return Int(tries)
    }
    
    /// Set the timestamp of the last passcode try.
    ///
    /// - Parameter timestamp: The last time the user tried a passcode
    /// - Throws: Valet/Keychain exceptions on fail
    public func setPasscodeTriedTimestamp(_ timestamp: TimeInterval) throws {
        log.verbose("Setting passcode tried timestamp")
        try globals().setString(String(timestamp), forKey: Key.PASSCODE_TRIED_TIMESTAMP)
    }
    
    /// Get the timestamp of the last passcode try.
    ///
    /// - Returns: The last time the user tried a passcode
    public func getPasscodeTriedTimestamp() -> TimeInterval? {
        guard let tries = try? globals().string(forKey: Key.PASSCODE_TRIED_TIMESTAMP) else {
            return nil
        }
        
        return TimeInterval(tries)
    }
    
    /// Set the previous application build version.
    ///
    /// - Parameter build: The new 'previous build'.
    /// - Throws: Valet/Keychain exceptions on fail
    public func setPreviousBuild(_ build: Int) throws {
        log.verbose("Setting previous build")
        try settings().setString(String(build), forKey: Key.PREVIOUS_BUILD)
    }
    
    /// Get the previous application build version.
    ///
    /// - Returns: The previous build
    public func getPreviousBuild() -> Int? {
        guard let build = try? settings().string(forKey: Key.PREVIOUS_BUILD) else {
            return nil
        }
        
        return Int(build)
    }
    
    /// Set the complete encryption key (password+passcode) in Secure Enclave.
    ///
    /// - Parameter key: The encryption key
    /// - Throws: Valet/Keychain exceptions on fail
    public func setEncryptionKey(_ key: String?) throws {
        log.verbose("Setting encryption key")
        
        if let key = key {
            try secrets().setString(key, forKey: Key.ENCRYPTION_KEY)
        } else {
            try secrets().removeObject(forKey: Key.ENCRYPTION_KEY)
        }
    }
    
    /// Get the complete encryption key (password+passcode) from Secure Enclave
    ///
    /// - Parameter prompt: The biometric unlock message to show
    /// - Returns: The encryption key
    public func getEncryptionKey(prompt: String) -> String? {
        return try? secrets().string(forKey: Key.ENCRYPTION_KEY, withPrompt: prompt)
    }
    
    /// Set a boolean representing if TouchID unlock is enabled.
    ///
    /// - Parameter enabled: Positive if TouchID unlock is enabled
    /// - Throws: Valet/Keychain exceptions on fail
    @available(*, deprecated, message: "TouchID has been migrated to Biometric Authentication since build 11.")
    public func setTouchIDUnlockEnabled(_ enabled: Bool) throws {
        log.verbose("Setting TouchID unlock enabled")
        
        try  globals().setString(String(enabled), forKey: Key.TOUCHID_ENABLED)
    }
    
    /// Check if TouchID unlock is currently enabled.
    ///
    /// - Returns: Positive if biometric unlock is enabled
    @available(*, deprecated, message: "TouchID has been migrated to Biometric Authentication since build 11.")
    public func getTouchIDUnlockEnabled() -> Bool {
        guard let enabled = try? globals().string(forKey: Key.TOUCHID_ENABLED) else {
            return false
        }
        
        return Bool(enabled) ?? false
    }
    
    /// Set a boolean representing if biometric unlock is enabled.
    ///
    /// - Parameter enabled: Positive if biometric unlock is enabled
    /// - Throws: Valet/Keychain exceptions on fail
    public func setBiometricUnlockEnabled(_ enabled: Bool) throws {
        log.verbose("Setting biometric unlock enabled")
        
        try globals().setString(String(enabled), forKey: Key.BIOMETRIC_AUTHENTICATION_ENABLED)
    }
    
    /// Check if biometric unlock is currently enabled.
    ///
    /// - Returns: Positive if biometric unlock is enabled
    public func getBiometricUnlockEnabled() -> Bool {
        guard let enabled = try? globals().string(forKey: Key.BIOMETRIC_AUTHENTICATION_ENABLED) else {
            return false
        }
        
        return Bool(enabled) ?? false
    }
    
    /// Set a boolean representing if previous password visibility is enabled.
    ///
    /// - Parameter enabled: Positive if previous password visibility is enabled
    public func setPreviousPasswordEnabled(_ enabled: Bool) throws {
        log.verbose("Setting previous password visibility enabled to \(enabled)")
        
        try globals().setString(String(enabled), forKey: Key.PREVIOUS_PASSWORD_ENABLED)
    }
    
    /// Check if previous password visibility is currently enabled.
    ///
    /// - Returns: Positive if previous password visibility is enabled
    public func getPreviousPasswordEnabled() -> Bool {
        guard let enabled = try? globals().string(forKey: Key.PREVIOUS_PASSWORD_ENABLED) else {
            return true
        }
        
        return Bool(enabled) ?? true
    }
    
    /// Set a boolean representing if local file logging is enabled.
    ///
    /// - Parameter enabled: Positive if local file logging is enabled.
    /// - Throws: Valet/Keychain exceptions on fail 
    public func setFileLoggingEnabled(_ enabled: Bool) throws {
        log.verbose("Setting file logging enabled")
        
        try globals().setString(String(enabled), forKey: Key.FILE_LOGGING_ENABLED)
    }
    
    /// Check if local file logging is enabled.
    ///
    /// - Returns: Positive if local file logging is enabled.
    public func getFileLoggingEnabled() -> Bool {
        guard let enabled = try? globals().string(forKey: Key.FILE_LOGGING_ENABLED) else {
            return false
        }
        
        return Bool(enabled) ?? false
    }
    
}
