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

class SetupFlowHelper {
    
    static let correctPassword = "ByxFc8F24wfWtY"
    
    static let invalidPasswordTooShort = "ByxF"
    
    static let invalidPasswordTooWeak = "123456789"
    
    static let correctPasscode = "112233"
    
    static let incorrectPasscode = "445566"
    
    static func forwardToWelcome(_ app: XCUIApplication) {
        // start is welcome, nothing to do.
        HumanDelayHelper.idle()
    }
    
    static func forwardToWelcomeSettings(_ app: XCUIApplication) {
        forwardToWelcome(app)
        
        _ = app.navigationBars.children(matching: .button).firstMatch.waitForExistence(timeout: 2)
        app.navigationBars.children(matching: .button).firstMatch.tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToStorage(_ app: XCUIApplication) {
        forwardToWelcome(app)
        
        _ = app.buttons["continue"].waitForExistence(timeout: 2)
        app.buttons["continue"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasswordInitial(_ app: XCUIApplication) {
        forwardToStorage(app)
        
        _ = app.buttons["continue"].waitForExistence(timeout: 2)
        app.buttons["continue"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasswordConfirmation(_ app: XCUIApplication, initialPassword: String = SetupFlowHelper.correctPassword) {
        forwardToPasswordInitial(app)
        
        _ = app.secureTextFields["passwordInitial"].waitForExistence(timeout: 2)
        app.secureTextFields["passwordInitial"].typeText(initialPassword)
        app.buttons["continue"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasscodeInitial(_ app: XCUIApplication, confirmationPassword: String = SetupFlowHelper.correctPassword) {
        forwardToPasswordConfirmation(app)
        
        _ = app.secureTextFields["passwordConfirmation"].waitForExistence(timeout: 2)
        app.secureTextFields["passwordConfirmation"].typeText(confirmationPassword)
        app.buttons["confirm"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasscodeConfirmation(_ app: XCUIApplication, initialPasscode: String = SetupFlowHelper.correctPasscode) {
        forwardToPasscodeInitial(app)
        
        _ = app.secureTextFields["passcodeInitial"].waitForExistence(timeout: 2)
        app.secureTextFields["passcodeInitial"].typeText(initialPasscode)
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToBiometrics(_ app: XCUIApplication, confirmationPasscode: String = SetupFlowHelper.correctPasscode) {
        forwardToPasscodeConfirmation(app)
        
        _ = app.secureTextFields["passcodeConfirmation"].waitForExistence(timeout: 2)
        app.secureTextFields["passcodeConfirmation"].typeText(confirmationPasscode)
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToCompletion(_ app: XCUIApplication) {
        if BiometricHelper.shared.biometricsAvailable() {
            forwardToBiometrics(app)
        } else {
            forwardToPasscodeConfirmation(app)
        }
        
        _ = app.buttons["enable"].waitForExistence(timeout: 2)
        app.buttons["enable"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToCompletionSettings(_ app: XCUIApplication) {
        forwardToCompletion(app)
        
        _ = app.navigationBars.children(matching: .button).firstMatch.waitForExistence(timeout: 2)
        app.navigationBars.children(matching: .button).firstMatch.tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToMain(_ app: XCUIApplication) {
        forwardToCompletion(app)
        
        _ = app.buttons["start"].waitForExistence(timeout: 2)
        app.buttons["start"].tap()
        
        HumanDelayHelper.idle()
    }

}
