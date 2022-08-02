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
