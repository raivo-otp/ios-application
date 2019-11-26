//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
//

import XCTest
import SwiftMonkey

class SetupMonkeyUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--ResetState", "--MonkeyPaws"]
        app.launch()
    }

    override func tearDown() {
        // Not implemented
    }
    
    func testWelcomeByMonkey() {
        let monkey = Monkey(frame: app.frame)

        monkey.addDefaultUIAutomationActions()
        monkey.addXCTestTapAlertAction(interval: 100, application: app)
        monkey.monkeyAround(forDuration: TimeInterval(60 * 2))
    }
    
}
