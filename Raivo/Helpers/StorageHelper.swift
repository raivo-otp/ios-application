//
//  StorageHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 08/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Valet
import LocalAuthentication

class StorageHelper {
    
    private static let KEY_PASSWORD = "EncryptionPassword"
    private static let KEY_LOCKSCREEN_TIMEOUT = "LockscreenTimeout"
    private static let KEY_REALM_FILENAME = "RealmFilename"
    private static let KEY_SYNCHRONIZATION_PROVIDER = "SynchronizationProvider"
    private static let KEY_SYNCHRONIZATION_ACCOUNT_IDENTIFIER = "SynchronizationProviderAccountIdentifier"
    private static let KEY_ICONS_EFFECT = "IconsEffect"
    private static let KEY_PINCODE_TRIED_AMOUNT = "PincodeTriedAmount"
    private static let KEY_PINCODE_TRIED_TIMESTAMP = "PincodeTriedTimestamp"
    private static let KEY_PREVIOUS_BUILD = "PreviousBuild"
    private static let KEY_ENCRYPTION_KEY = "EncryptionKey"
    private static let KEY_TOUCHID_ENABLED = "TouchIDEnabled"
    
    private static func settings() -> Valet {
        return Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .whenUnlocked)
    }
    
    private static func secrets() -> SecureEnclaveValet {
        return SecureEnclaveValet.valet(with: Identifier(nonEmpty: "secrets")!, accessControl: .userPresence)
    }
    
    public static func clear() {
        settings().removeAllObjects()
        secrets().removeAllObjects()
    }
    
    public static func canAccessSecrets() -> Bool {
        var error: NSError?
        
        let hasTouchID = LAContext().canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        
        guard error?.code != LAError.touchIDNotAvailable.rawValue else {
            return false
        }
        
        return hasTouchID
    }
    
    public static func setEncryptionPassword(_ password: String) {
        settings().set(string: password, forKey: KEY_PASSWORD)
    }
    
    public static func getEncryptionPassword() -> String? {
        return settings().string(forKey: KEY_PASSWORD)
    }
    
    public static func setLockscreenTimeout(_ seconds: TimeInterval) {
        settings().set(string: String(seconds), forKey: KEY_LOCKSCREEN_TIMEOUT)
    }
    
    public static func getLockscreenTimeout() -> TimeInterval? {
        guard let timeout = settings().string(forKey: KEY_LOCKSCREEN_TIMEOUT) else {
            return nil
        }
        
        return TimeInterval(timeout)
    }
    
    public static func setRealmFilename(_ filename: String) {
        settings().set(string: filename, forKey: KEY_REALM_FILENAME)
    }
    
    public static func getRealmFilename() -> String? {
        return settings().string(forKey: KEY_REALM_FILENAME)
    }
    
    public static func setSynchronizationProvider(_ provider: String) {
        settings().set(string: provider, forKey: KEY_SYNCHRONIZATION_PROVIDER)
    }
    
    public static func getSynchronizationProvider() -> String? {
        return settings().string(forKey: KEY_SYNCHRONIZATION_PROVIDER)
    }
    
    public static func setSynchronizationAccountIdentifier(_ accountIdentifier: String) {
        settings().set(string: accountIdentifier, forKey: KEY_SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
    }
    
    public static func getSynchronizationAccountIdentifier() -> String? {
        return settings().string(forKey: KEY_SYNCHRONIZATION_ACCOUNT_IDENTIFIER)
    }
    
    public static func setIconsEffect(_ effect: String) {
        settings().set(string: effect, forKey: KEY_ICONS_EFFECT)
    }
    
    public static func getIconsEffect() -> String? {
        return settings().string(forKey: KEY_ICONS_EFFECT)
    }
    
    public static func setPincodeTriedAmount(_ tries: Int) {
        settings().set(string: String(tries), forKey: KEY_PINCODE_TRIED_AMOUNT)
    }
    
    public static func getPincodeTriedAmount() -> Int? {
        guard let tries = settings().string(forKey: KEY_PINCODE_TRIED_AMOUNT) else {
            return nil
        }
        
        return Int(tries)
    }
    
    public static func setPincodeTriedTimestamp(_ timestamp: TimeInterval) {
        settings().set(string: String(timestamp), forKey: KEY_PINCODE_TRIED_TIMESTAMP)
        
    }
    
    public static func getPincodeTriedTimestamp() -> TimeInterval? {
        guard let tries = settings().string(forKey: KEY_PINCODE_TRIED_TIMESTAMP) else {
            return nil
        }
        
        return TimeInterval(tries)
    }
    
    public static func setPreviousBuild(_ build: Int) {
        settings().set(string: String(build), forKey: KEY_PREVIOUS_BUILD)
    }
    
    public static func getPreviousBuild() -> Int? {
        guard let build = settings().string(forKey: KEY_PREVIOUS_BUILD) else {
            return nil
        }
        
        return Int(build)
    }
    
    public static func setEncryptionKey(_ key: String?) {
        if let key = key {
            secrets().set(string: key, forKey: KEY_ENCRYPTION_KEY)
        } else {
            secrets().removeObject(forKey: KEY_ENCRYPTION_KEY)
        }
    }
    
    public static func getEncryptionKey(prompt: String) -> String? {
        let result = secrets().string(forKey: KEY_ENCRYPTION_KEY, withPrompt: prompt)
        
        switch result {
        case .success(let key):
            return key
        default:
            return nil
        }
    }
    
    public static func setBiometricUnlockEnabled(_ enabled: Bool) {
        settings().set(string: String(enabled), forKey: KEY_TOUCHID_ENABLED)
    }
    
    public static func getBiometricUnlockEnabled() -> Bool {
        guard let build = settings().string(forKey: KEY_TOUCHID_ENABLED) else {
            return false
        }
        
        return Bool(build) ?? false
    }
    
}
