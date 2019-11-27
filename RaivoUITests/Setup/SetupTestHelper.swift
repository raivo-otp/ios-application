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

class SetupTestHelper {
    
    static func forwardToWelcome(_ app: XCUIApplication) {
        // start is welcome, nothing to do.
    }
    
    static func forwardToStorage(_ app: XCUIApplication) {
        forwardToWelcome(app)
        app.buttons["continue"].tap()
    }
    
    static func forwardToPasswordInitial(_ app: XCUIApplication) {
        forwardToStorage(app)
        app.buttons["continue"].tap()
    }
    
    static func forwardToPasswordConfirmation(_ app: XCUIApplication, initialPassword: String = "12345678") {
        forwardToPasswordInitial(app)
        app.secureTextFields["passwordInitial"].tap()
        app.secureTextFields["passwordInitial"].typeText(initialPassword)
        app.buttons["continue"].tap()
    }
    
    static func forwardToPasscodeInitial(_ app: XCUIApplication, confirmationPassword: String = "12345678") {
        forwardToPasswordConfirmation(app)
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText(confirmationPassword)
        app.buttons["confirm"].tap()
    }
    
    static func forwardToPasscodeConfirmation(_ app: XCUIApplication, initialPasscode: String = "123456") {
        forwardToPasscodeInitial(app)
        app.secureTextFields["passcodeInitial"].typeText(initialPasscode)
    }
    
    static func forwardToCompletion(_ app: XCUIApplication, confirmationPasscode: String = "123456") {
        forwardToPasscodeConfirmation(app)
        app.secureTextFields["passcodeConfirmation"].typeText(confirmationPasscode)
    }
    
    static func forwardToMain(_ app: XCUIApplication) {
        forwardToCompletion(app)
        app.buttons["start"].tap()
    }

}
