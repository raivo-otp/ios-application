//
//  PincodeDigitsProtocol.swift
//  Raivo
//
//  Created by Tijme Gommers on 13/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

protocol PincodeDigitsProtocol : class {
    
    func onPincodeComplete(pincode: String) -> Void
    
    func onBiometricsTrigger() -> Void
    
}
