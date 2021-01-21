//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import XCTest

/// A helper class for human interaction during a UITest
class HumanDelayHelper {
  
    /// This is basically a 'sleep' function that impersonates a user waiting.
    ///
    /// - Parameter seconds: The amount of seconds to wait/sleep
    /// - Returns: An 'XCTWaiter.Result' timeout if the amount of seconds were passed
    @discardableResult
    static func idle(_ seconds: TimeInterval = 1.0) -> XCTWaiter.Result {
        return XCTWaiter.wait(for: [XCTestExpectation(description: "User is idle...")], timeout: seconds)
    }

}
