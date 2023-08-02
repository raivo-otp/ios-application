//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import XCTest

class SetupRoboticTest: XCTestCase {
    
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--ResetState", "--DisableBiometrics"]
        app.launch()
    }

    override func tearDown() {
        // No actions required
    }
    
    func testWelcome() {
        SetupFlowHelper.forwardToWelcome(app)
        
        XCTAssertTrue(app.otherElements["setupWelcome"].exists)
    }
    
    func testWelcomeSettings() {
        SetupFlowHelper.forwardToWelcomeSettings(app)
        
        XCTAssertTrue(app.otherElements["setupSettings"].exists)
        XCTAssertFalse(app.otherElements["miscSignOut"].exists)
    }
    
    func testStorage() {
        SetupFlowHelper.forwardToStorage(app)
        
        XCTAssertTrue(app.otherElements["setupStorage"].exists)
        XCTAssertTrue(app.buttons["continue"].exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: app.buttons["continue"], handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testMinimumPasswordLengthToShort() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText(SetupFlowHelper.invalidPasswordTooShort)
        
        app.buttons["continue"].tap()
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasswordInitial"].exists)
    }
    
    func testMinimumPasswordLengthLongEnough() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText(SetupFlowHelper.correctPassword)
        
        app.buttons["continue"].tap()
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasswordConfirmation"].exists)
    }
    
    func testInvalidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: SetupFlowHelper.correctPassword)
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("BBBBBBBBBB")
        
        XCTAssertTrue(app.otherElements["setupPasswordInitial"].exists)
    }
    
    func testValidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: SetupFlowHelper.correctPassword)
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText(SetupFlowHelper.correctPassword)
        
        app.buttons["confirm"].tap()
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasscodeInitial"].exists)
    }
    
    func testMinimumPasscodeLengthToShort() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("1234")
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasscodeInitial"].exists)
    }
    
    func testMinimumPasscodeLengthLongEnough() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText(SetupFlowHelper.correctPasscode)
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasscodeConfirmation"].exists)
    }
    
    func testInvalidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: SetupFlowHelper.correctPasscode)
        
        app.secureTextFields["passcodeConfirmation"].typeText("445566")
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupPasscodeInitial"].exists)
    }
    
    func testValidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: "665544")
        
        app.secureTextFields["passcodeConfirmation"].typeText("665544")
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["setupBiometrics"].exists)
    }
    
    func testBiometrics() {
        if !BiometricHelper.shared.biometricsAvailable() {
            // Biometrics are not available
            return
        }
        
        SetupFlowHelper.forwardToBiometrics(app)
        HumanDelayHelper.idle(1)
        
        app.buttons["enable"].tap()
        HumanDelayHelper.idle(1)
        
        XCTAssertTrue(app.otherElements["setupComplete"].exists)
    }
    
    func testCompletion() {
        SetupFlowHelper.forwardToCompletion(app)
        
        app.buttons["start"].tap()
        HumanDelayHelper.idle()
        
        XCTAssertTrue(app.otherElements["mainPasswords"].exists)
    }
    
    func testCompletionSettings() {
        SetupFlowHelper.forwardToCompletionSettings(app)
        
        XCTAssertTrue(app.otherElements["setupSettings"].exists)
        XCTAssertFalse(app.otherElements["miscSignOut"].exists)
    }

}
