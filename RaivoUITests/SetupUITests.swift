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

class SetupUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Not implemented
    }

    func testWelcome() {
        XCTAssertTrue(app.buttons["continueToStorage"].exists)
    }
    
    func testWelcomeToStorage() {
        app.buttons["continueToStorage"].tap()
    }
    
    func testStorage() {
        let continueToEncryption = app.buttons["continueToEncryption"]
        XCTAssertTrue(continueToEncryption.exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: continueToEncryption, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testStorageToEncryption() {
        app.buttons["continueToEncryption"].tap()
    }
    
    func testMinimumPasswordLength() {
        app.buttons["continueToEncryption"].tap()
    }

}
