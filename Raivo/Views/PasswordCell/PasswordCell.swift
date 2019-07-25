//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
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
