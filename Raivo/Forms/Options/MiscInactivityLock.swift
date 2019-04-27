//
//  MiscInactivityLock.swift
//  Raivo
//
//  Created by Tijme Gommers on 07/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class MiscInactivityLock: CustomStringConvertible, Equatable {
    
    var seconds: Int
    var description: String
    
    init(_ seconds: Int) {
        self.seconds = seconds
        self.description = String(seconds)
    }
    
    init(_ seconds: Int, _ description: String) {
        self.seconds = seconds
        self.description = description
    }
    
    static func == (lhs: MiscInactivityLock, rhs: MiscInactivityLock) -> Bool {
        return lhs.seconds == rhs.seconds
    }
    
}
