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

class SetupHumanUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--ResetState"]
        app.launch()
    }

    override func tearDown() {
        // Not implemented
    }
    
    func testWelcome() {
        let continueToStorage = app.buttons["continueToStorage"]
        XCTAssertTrue(continueToStorage.exists)
    }
    
    func testWelcomeByMonkey() {
        let monkey = Monkey(frame: app.frame)

        monkey.addDefaultUIAutomationActions()
        monkey.addXCTestTapAlertAction(interval: 100, application: app)
        monkey.monkeyAround(forDuration: TimeInterval(60 * 2))
    }
    
    func testStorage() {
        app.buttons["continueToStorage"].tap()
        
        let continueToEncryption = app.buttons["continueToEncryption"]
        XCTAssertTrue(continueToEncryption.exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: continueToEncryption, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMinimumPasswordLength() {
        app.buttons["continueToStorage"].tap()
        app.buttons["continueToEncryption"].tap()
        
        app.textFields["password"].tap()
        app.textFields["password"].typeText("")
        
        // password
        // continueToConfirmation
        // continueToPasscode
        
        // Not implemented
    }

}
