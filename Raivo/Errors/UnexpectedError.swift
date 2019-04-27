//
//  UnexpectedError.swift
//  Raivo
//
//  Created by Tijme Gommers on 14/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class UnexpectedError: LocalizedError {
    
    var message = ""
    
    var errorDescription: String? {
        get {
            return self.message
        }
    }
    
    init(_ message: String) {
        self.message = message
    }

}
