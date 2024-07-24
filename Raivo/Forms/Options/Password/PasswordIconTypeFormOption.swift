//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation

public class PasswordIconTypeFormOption: BaseFormOption {
    
    static let OPTION_CLEAR = PasswordIconTypeFormOption("clear", description: "Remove current icon")
    static let OPTION_CUSTOM_ICONS = PasswordIconTypeFormOption("custom_icons", description: "Custom Icons")
	static let OPTION_RAIVO_REPOSITORY = PasswordIconTypeFormOption("raivo_repository", description: "Raivo's icon repository")
    
    static let options_including_clear = [
        OPTION_CLEAR,
		OPTION_CUSTOM_ICONS,
        OPTION_RAIVO_REPOSITORY
    ]
    
    static let options = Array(PasswordIconTypeFormOption.options_including_clear.suffix(from: 1))
    
    public var value: String
    
    public var description: String
    
    init(_ value: String, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: String) -> PasswordIconTypeFormOption? {
        for option in options {
            if option.value.elementsEqual(value) {
                return option
            }
        }
        
        return nil
    }
    
    public static func == (lhs: PasswordIconTypeFormOption, rhs: PasswordIconTypeFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}
