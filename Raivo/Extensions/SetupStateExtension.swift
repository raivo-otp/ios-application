//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import UIKit

/// Allow Setup controllers on the stack (including popovers) to get a reference to the shared setup state
protocol SetupState {

    /// Allow Setup controllers on the stack (including popovers) to get a reference to the shared setup state
    func state(_ controller: UIViewController) -> SetupStateObject
    
}

extension SetupState {

    /// Allow Setup controllers on the stack (including popovers) to get a reference to the shared setup state
    ///
    /// - Parameter controller: Either a non-popover controller on the stack, or the root view controller.
    /// - Returns: The shared setup state.
    func state(_ controller: UIViewController) -> SetupStateObject {
        if let reference = controller as? SetupRootViewController {
            return reference.state
        }
        
        return (controller.navigationController as! SetupRootViewController).state
    }
    
}
