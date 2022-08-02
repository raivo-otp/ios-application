//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import Eureka

class MiscellaneousInactivityLockFormOption: BaseFormOption {
    
    static let OPTION_20_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(20), description: "20 seconds")
    static let OPTION_30_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(30), description: "30 seconds")
    static let OPTION_60_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(60), description: "1 minute")
    static let OPTION_120_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(120), description: "2 minutes")
    static let OPTION_300_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(300), description: "5 minutes")
    static let OPTION_600_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(600), description: "10 minutes")
    static let OPTION_86400_SECONDS = MiscellaneousInactivityLockFormOption(TimeInterval(86400), description: "1 day")
    
    static let OPTION_DEFAULT = OPTION_300_SECONDS
    
    static let options = [
        OPTION_20_SECONDS,
        OPTION_30_SECONDS,
        OPTION_60_SECONDS,
        OPTION_120_SECONDS,
        OPTION_300_SECONDS,
        OPTION_600_SECONDS,
        OPTION_86400_SECONDS
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
