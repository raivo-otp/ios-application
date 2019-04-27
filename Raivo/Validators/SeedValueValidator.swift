//
//  SeedValueValidator.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import OneTimePassword

class SeedValueValidator {
    
    static func isValid(_ uri: String) -> Bool {
        guard let uri = URL(string: uri) else {
            return false
        }
        
        guard Token(url: uri) != nil else {
            return false
        }
        
        return true
    }
    
}
