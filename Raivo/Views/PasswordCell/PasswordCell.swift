//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
//

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
