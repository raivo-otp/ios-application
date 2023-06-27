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

class SetupRoboticTest: XCTestCase {
    
    var app: XCUIApplication!
        
    private let unitTestPasswordUncompliantShort = "12345"
    
    private let unitTestPasswordUncompliantWeak = "123456789"

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
        
        let setupWelcome = app.otherElements["setupWelcome"]
        XCTAssertTrue(setupWelcome.exists)
    }
    
    func testWelcomeSettings() {
        SetupFlowHelper.forwardToWelcomeSettings(app)
        
        let changelog = app.otherElements["setupSettings"]
        XCTAssertTrue(changelog.exists)
        
        let signOut = app.otherElements["miscSignOut"]
        XCTAssertFalse(signOut.exists)
    }
    
    func testStorage() {
        SetupFlowHelper.forwardToStorage(app)
        
        let setupStorage = app.otherElements["setupStorage"]
        XCTAssertTrue(setupStorage.exists)
        
        let continueButton = app.buttons["continue"]
        XCTAssertTrue(continueButton.exists)
        
        let buttonEnabled = NSPredicate(format: "isEnabled == true")
        expectation(for: buttonEnabled, evaluatedWith: continueButton, handler: nil)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testMinimumPasswordLengthToShort() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText(unitTestPasswordUncompliantShort)
        
        app.buttons["continue"].tap()
        HumanDelayHelper.idle()
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testMinimumPasswordLengthLongEnough() {
        SetupFlowHelper.forwardToPasswordInitial(app)
        
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText(SetupFlowHelper.correctPassword)
        
        app.buttons["continue"].tap()
        HumanDelayHelper.idle()
        
        let setupPasswordConfirmation = app.otherElements["setupPasswordConfirmation"]
        XCTAssertTrue(setupPasswordConfirmation.exists)
    }
    
    func testInvalidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: SetupFlowHelper.correctPassword)
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("BBBBBBBBBB")
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
    }
    
    func testValidPasswordConfirmation() {
        SetupFlowHelper.forwardToPasswordConfirmation(app, initialPassword: SetupFlowHelper.correctPassword)
        
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText(SetupFlowHelper.correctPassword)
        
        app.buttons["confirm"].tap()
        HumanDelayHelper.idle()
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthToShort() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText("1234")
        HumanDelayHelper.idle()
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testMinimumPasscodeLengthLongEnough() {
        SetupFlowHelper.forwardToPasscodeInitial(app)
        
        app.secureTextFields["passcodeInitial"].typeText(SetupFlowHelper.correctPasscode)
        HumanDelayHelper.idle()
        
        let setupPasscodeConfirmation = app.otherElements["setupPasscodeConfirmation"]
        XCTAssertTrue(setupPasscodeConfirmation.exists)
    }
    
    func testInvalidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: SetupFlowHelper.correctPasscode)
        
        app.secureTextFields["passcodeConfirmation"].typeText("445566")
        HumanDelayHelper.idle()
        
        let setupPasscodeInitial = app.otherElements["setupPasscodeInitial"]
        XCTAssertTrue(setupPasscodeInitial.exists)
    }
    
    func testValidPasscodeConfirmation() {
        SetupFlowHelper.forwardToPasscodeConfirmation(app, initialPasscode: "665544")
        
        app.secureTextFields["passcodeConfirmation"].typeText("665544")
        HumanDelayHelper.idle()
        
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
        HumanDelayHelper.idle()
        
        let setupCompletion = app.otherElements["setupComplete"]
        XCTAssertTrue(setupCompletion.exists)
    }
    
    func testCompletion() {
        SetupFlowHelper.forwardToCompletion(app)
        
        app.buttons["start"].tap()
        HumanDelayHelper.idle()
        
        let mainPasswords = app.otherElements["mainPasswords"]
        XCTAssertTrue(mainPasswords.exists)
    }
    
    func testCompletionSettings() {
        SetupFlowHelper.forwardToCompletionSettings(app)
        
        let changelog = app.otherElements["setupSettings"]
        XCTAssertTrue(changelog.exists)
        
        let signOut = app.otherElements["miscSignOut"]
        XCTAssertFalse(signOut.exists)
    }

}
