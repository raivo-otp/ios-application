//
//  MiscInactivityLockOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 07/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class MiscInactivityLockOption: CustomStringConvertible, Equatable {
    
    static let defaultOption = options[4]
    
    static let options = [
        MiscInactivityLockOption(20, "20 seconds"),
        MiscInactivityLockOption(30, "30 seconds"),
        MiscInactivityLockOption(60, "1 minute"),
        MiscInactivityLockOption(120, "2 minutes"),
        MiscInactivityLockOption(300, "5 minutes"),
        MiscInactivityLockOption(600, "10 minutes")
    ]
    
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
    
    static func == (lhs: MiscInactivityLockOption, rhs: MiscInactivityLockOption) -> Bool {
        return lhs.seconds == rhs.seconds
    }
    
}
