//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import Eureka

class MiscellaneousInactivityLockFormOption: BaseFormOption {
    
    static let OPTION_20_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(20), description: "20 seconds")
    static let OPTION_30_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(30), description: "30 seconds")
    static let OPTION_60_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(60), description: "1 minute")
    static let OPTION_120_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(120), description: "2 minutes")
    static let OPTION_300_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(300), description: "5 minutes")
    static let OPTION_600_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(600), description: "10 minutes")
    
    static let OPTION_DEFAULT = OPTION_300_SECONDS
    
    static let options = [
        OPTION_20_SECONDS,
        OPTION_30_SECONDS,
        OPTION_60_SECONDS,
        OPTION_120_SECONDS,
        OPTION_300_SECONDS,
        OPTION_600_SECONDS
    ]
    
    var value: TimeInterval
    var description: String
    
    init(_ value: TimeInterval, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: TimeInterval) -> MiscellaneousInactivityLockFormOption? {
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
