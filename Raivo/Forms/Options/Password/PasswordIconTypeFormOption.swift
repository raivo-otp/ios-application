//
//  PasswordIconTypeFormOption.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

public class PasswordIconTypeFormOption: BaseFormOption {
    
    static let OPTION_RAIVO_REPOSITORY = PasswordIconTypeFormOption("raivo_repository", description: "Raivo's icon repository")
    
    static let options = [
        OPTION_RAIVO_REPOSITORY
    ]
    
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
