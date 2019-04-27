//
//  KeychainHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 08/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Valet

class KeychainHelper {
    
    static let KEY_PASSWORD = "EncryptionPassword"
    
    static let KEY_LOCKSCREEN_TIMEOUT = "LockscreenTimeout"
    
    static let KEY_REALM_FILENAME = "RealmFilename"
    
    static let KEY_SYNCHRONIZATION_PROVIDER = "SynchronizationProvider"
    
    static let KEY_PINCODE_TRIED_AMOUNT = "PincodeTriedAmount"
    
    static let KEY_PINCODE_TRIED_TIMESTAMP = "PincodeTriedTimestamp"
    
    static let KEY_PREVIOUS_BUILD = "PreviousBuild"
    
    static func settings() -> Valet {
        return Valet.valet(with: Identifier(nonEmpty: "settings")!, accessibility: .whenUnlocked)
    }
    
    static func secrets() -> SecureEnclaveValet {
        return SecureEnclaveValet.valet(with: Identifier(nonEmpty: "secrets")!, accessControl: .userPresence)
    }
    
    static func clear() {
        settings().removeAllObjects()
//        secrets().removeAllObjects()
    }
    
}
