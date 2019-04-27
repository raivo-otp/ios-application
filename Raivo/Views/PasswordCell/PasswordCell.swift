//
//  PasswordCell.swift
//  Raivo
//
//  Created by Tijme Gommers on 10/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

class PasswordCell: UITableViewCell {
    
    internal func setPassword(_ password: Password) {
        log.error("The 'setPassword' function was called on 'PasswordCell' instead of it's subclass!")
    }
    
    internal func updateState(force: Bool = false) {
        log.error("The 'updateState' function was called on 'PasswordCell' instead of it's subclass!")
    }
    
}
