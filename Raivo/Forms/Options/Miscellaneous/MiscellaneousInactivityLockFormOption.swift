//
//  MiscellaneousInactivityLockFormOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 07/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import Eureka

class MiscellaneousInactivityLockFormOption: BaseFormOption {
    
    static let OPTION_20_SECONDS = MiscellaneousInactivityLockFormOption(20, description: "20 seconds")
    static let OPTION_30_SECONDS = MiscellaneousInactivityLockFormOption(30, description: "30 seconds")
    static let OPTION_60_SECONDS = MiscellaneousInactivityLockFormOption(60, description: "1 minute")
    static let OPTION_120_SECONDS = MiscellaneousInactivityLockFormOption(120, description: "2 minutes")
    static let OPTION_300_SECONDS = MiscellaneousInactivityLockFormOption(300, description: "5 minutes")
    static let OPTION_600_SECONDS = MiscellaneousInactivityLockFormOption(600, description: "10 minutes")
    
    static let OPTION_DEFAULT = OPTION_300_SECONDS
    
    static let options = [
        OPTION_20_SECONDS,
        OPTION_30_SECONDS,
        OPTION_60_SECONDS,
        OPTION_120_SECONDS,
        OPTION_300_SECONDS,
        OPTION_600_SECONDS
    ]
    
    var value: Int
    var description: String
    
    init(_ value: Int, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: Int) -> MiscellaneousInactivityLockFormOption? {
        for option in options {
            if option.value == value {
                return option
            }
        }
        
        return nil
    }
    
    static func == (lhs: MiscellaneousInactivityLockFormOption, rhs: MiscellaneousInactivityLockFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}
