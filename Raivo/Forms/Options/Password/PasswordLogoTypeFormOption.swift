//
//  PasswordLogoTypeFormOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

public class PasswordLogoTypeFormOption: BaseFormOption {
    
    static let OPTION_RAIVO_VECTOR = PasswordLogoTypeFormOption("raivo_vector", description: "Choose from Raivo vectors")
    
    static let options = [
        OPTION_RAIVO_VECTOR
    ]
    
    public var value: String
    
    public var description: String
    
    init(_ value: String, description: String) {
        self.value = value
        self.description = description
    }
    
    static func build(_ value: String) -> PasswordLogoTypeFormOption? {
        for option in options {
            if option.value.elementsEqual(value) {
                return option
            }
        }
        
        return nil
    }
    
    public static func == (lhs: PasswordLogoTypeFormOption, rhs: PasswordLogoTypeFormOption) -> Bool {
        return lhs.value == rhs.value
    }
    
}
