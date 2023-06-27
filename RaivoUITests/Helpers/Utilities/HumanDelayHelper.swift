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

import XCTest

/// A helper class for human interaction during a UITest
class HumanDelayHelper {
  
    /// This is basically a 'sleep' function that impersonates a user waiting.
    ///
    /// - Parameter seconds: The amount of seconds to wait/sleep
    /// - Returns: An 'XCTWaiter.Result' timeout if the amount of seconds were passed
    @discardableResult
    static func idle(_ seconds: TimeInterval = 0.25) -> XCTWaiter.Result {
        return XCTWaiter.wait(for: [XCTestExpectation(description: "User is idle...")], timeout: seconds)
    }

}
