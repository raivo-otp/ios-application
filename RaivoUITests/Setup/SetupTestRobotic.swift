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

import XCTest

class SetupTestRobotic: XCTestCase {
    
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
        SetupTestHelper.forwardToWelcome(app)
        
        let setupWelcome = app.otherElements["setupWelcome"]
        XCTAssertTrue(setupWelcome.exists)
    }
    
    func testStorage() {
        SetupTestHelper.forwardToStorage(app)
        
        let setupStorage = app.otherElements["setupStorage"]
        XCTAssertTrue(setupStorage.exists)
        
        let continueButton = app.buttons["continue"]
        XCTAssertTrue(continueButton.exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: continueButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMinimumPasswordLengthToShort() {
        SetupTestHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText("1234567")
        
        app.buttons["continue"].tap()
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testMinimumPasswordLengthLongEnough() {
        SetupTestHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText("12345678")
        
        app.buttons["continue"].tap()
        
        let setupPasswordConfirmation = app.otherElements["setupPasswordConfirmation"]
        XCTAssertTrue(setupPasswordConfirmation.exists)
    }
    
    func testInvalidPasswordConfirmation() {
        SetupTestHelper.forwardToPasswordConfirmation(app, initialPassword: "AAAAAAAAAA")
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("BBBBBBBBBB")
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testValidPasswordConfirmation() {
        SetupTestHelper.forwardToPasswordConfirmation(app, initialPassword: "AAAAAAAAAA")
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("AAAAAAAAAA")
        
        app.buttons["confirm"].tap()
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthToShort() {
        SetupTestHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("12345")
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthLongEnough() {
        SetupTestHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("123456")
        
        let setupPasscodeConfirmation = app.otherElements["setupPasscodeConfirmation"]
        XCTAssertTrue(setupPasscodeConfirmation.exists)
    }
    
    func testInvalidPasscodeConfirmation() {
        SetupTestHelper.forwardToPasscodeConfirmation(app, initialPasscode: "111111")
        
        app.secureTextFields["passcodeConfirmation"].typeText("222222")
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testValidPasscodeConfirmation() {
        SetupTestHelper.forwardToPasscodeConfirmation(app, initialPasscode: "654321")
        
        app.secureTextFields["passcodeConfirmation"].typeText("654321")
        
        let setupPasscodeInitial = app.otherElements["setupBiometrics"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testBiometrics() {
        SetupTestHelper.forwardToBiometrics(app)
        
        app.buttons["enable"].tap()
        
        let setupCompletion = app.otherElements["setupComplete"]
        XCTAssertTrue(setupCompletion.exists)
    }
    
    func testCompletion() {
        SetupTestHelper.forwardToCompletion(app)
        
        app.buttons["start"].tap()
        
        let mainPasswords = app.otherElements["mainPasswords"]
        XCTAssertTrue(mainPasswords.exists)
    }

}
