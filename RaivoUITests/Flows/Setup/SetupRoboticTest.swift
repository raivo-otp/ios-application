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

class SetupRoboticTest: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--ResetState"]
        app.launch()
    }

    override func tearDown() {
        // No actions required
    }
    
    func testWelcome() {
        SetupFlowHelper.forwardToWelcome(app)
        
        let setupWelcome = app.otherElements["setupWelcome"]
        XCTAssertTrue(setupWelcome.exists)
    }
    
    func testStorage() {
        SetupFlowHelper.forwardToStorage(app)
        
        let setupStorage = app.otherElements["setupStorage"]
        XCTAssertTrue(setupStorage.exists)
        
        let continueButton = app.buttons["continue"]
        XCTAssertTrue(continueButton.exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: continueButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMinimumPasswordLengthToShort() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText("1234567")
        
        app.buttons["continue"].tap()
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testMinimumPasswordLengthLongEnough() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText("12345678")
        
        app.buttons["continue"].tap()
        
        let setupPasswordConfirmation = app.otherElements["setupPasswordConfirmation"]
        XCTAssertTrue(setupPasswordConfirmation.exists)
    }
    
    func testInvalidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: "AAAAAAAAAA")
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("BBBBBBBBBB")
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testValidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: "AAAAAAAAAA")
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("AAAAAAAAAA")
        
        app.buttons["confirm"].tap()
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthToShort() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("12345")
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthLongEnough() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("123456")
        
        let setupPasscodeConfirmation = app.otherElements["setupPasscodeConfirmation"]
        XCTAssertTrue(setupPasscodeConfirmation.exists)
    }
    
    func testInvalidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: "111111")
        
        app.secureTextFields["passcodeConfirmation"].typeText("222222")
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testValidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: "654321")
        
        app.secureTextFields["passcodeConfirmation"].typeText("654321")
        
        let setupPasscodeInitial = app.otherElements["setupBiometrics"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testBiometrics() {
        if !BiometricHelper.shared.biometricsAvailable() {
            // Biometrics are not available
            return
        }
        
        SetupFlowHelper.forwardToBiometrics(app)
        
        app.buttons["enable"].tap()
        
        let setupCompletion = app.otherElements["setupComplete"]
        XCTAssertTrue(setupCompletion.exists)
    }
    
    func testCompletion() {
        SetupFlowHelper.forwardToCompletion(app)
        
        app.buttons["start"].tap()
        
        let mainPasswords = app.otherElements["mainPasswords"]
        XCTAssertTrue(mainPasswords.exists)
    }

}
