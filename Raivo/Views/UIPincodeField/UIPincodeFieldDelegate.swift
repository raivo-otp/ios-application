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

/// The delegate that can be used to listen for UIPincodeField callbacks
protocol UIPincodeFieldDelegate {
    
    /// Triggered when a user has entered all the digits in the UIPincodeField
    ///
    /// - Parameter pincode: The final PIN code string
    func onPincodeComplete(pincode: String) -> Void
    
    /// Triggered when a user has entered or removed a digit in the UIPincodeField
    ///
    /// - Parameter pincode: The current (possibly incomplete) PIN code string
    func onPincodeChange(pincode: String) -> Void

}
