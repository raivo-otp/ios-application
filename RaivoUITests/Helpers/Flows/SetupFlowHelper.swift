//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import XCTest

class SetupFlowHelper {
    
    static func forwardToWelcome(_ app: XCUIApplication) {
        // start is welcome, nothing to do.
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
    
    static func forwardToPasswordConfirmation(_ app: XCUIApplication, initialPassword: String = "12345678") {
        forwardToPasswordInitial(app)
        
        _ = app.secureTextFields["passwordInitial"].waitForExistence(timeout: 2)
        app.secureTextFields["passwordInitial"].typeText(initialPassword)
        app.buttons["continue"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasscodeInitial(_ app: XCUIApplication, confirmationPassword: String = "12345678") {
        forwardToPasswordConfirmation(app)
        
        _ = app.secureTextFields["passwordConfirmation"].waitForExistence(timeout: 2)
        app.secureTextFields["passwordConfirmation"].typeText(confirmationPassword)
        app.buttons["confirm"].tap()
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToPasscodeConfirmation(_ app: XCUIApplication, initialPasscode: String = "123456") {
        forwardToPasscodeInitial(app)
        
        _ = app.secureTextFields["passcodeInitial"].waitForExistence(timeout: 2)
        app.secureTextFields["passcodeInitial"].typeText(initialPasscode)
        
        HumanDelayHelper.idle()
    }
    
    static func forwardToBiometrics(_ app: XCUIApplication, confirmationPasscode: String = "123456") {
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
    
    static func forwardToMain(_ app: XCUIApplication) {
        forwardToCompletion(app)
        
        _ = app.buttons["start"].waitForExistence(timeout: 2)
        app.buttons["start"].tap()
        
        HumanDelayHelper.idle()
    }

}
