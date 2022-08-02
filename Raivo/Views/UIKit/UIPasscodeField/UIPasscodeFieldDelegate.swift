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
