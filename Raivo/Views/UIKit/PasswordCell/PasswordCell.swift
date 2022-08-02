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
import UIKit
import SwipeCellKit

class PasswordCell: SwipeTableViewCell {
    
    internal func setPassword(_ password: Password) {
        log.error("The 'setPassword' function was called on 'PasswordCell' instead of it's subclass!")
    }
    
    internal func updateState(force: Bool = false) {
        log.error("The 'updateState' function was called on 'PasswordCell' instead of it's subclass!")
    }
    
}
