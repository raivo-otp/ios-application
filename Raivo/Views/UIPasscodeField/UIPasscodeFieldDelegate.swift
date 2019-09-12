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

/// The delegate that can be used to listen for UIPasscodeField callbacks
protocol UIPasscodeFieldDelegate {
    
    /// Triggered when a user has entered all the digits in the UIPasscodeField
    ///
    /// - Parameter passcode: The final passcode string
    func onPasscodeComplete(passcode: String) -> Void
    
    /// Triggered when a user has entered or removed a digit in the UIPasscodeField
    ///
    /// - Parameter passcode: The current (possibly incomplete) passcode string
    func onPasscodeChange(passcode: String) -> Void

}
