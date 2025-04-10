//
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

class AuthRoboticTest: XCTestCase {
    
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
    
    func testSignIn() {
        SetupFlowHelper.forwardToMain(app)
        
        // Terminate & launch app again
        app.launchArguments = ["--DisableBiometrics"]
        app.terminate()
        app.launch()
        
        HumanDelayHelper.idle()
        
        // Authentication screen must be visible after relaunch
        XCTAssertTrue(app.otherElements["authEntry"].exists)
        HumanDelayHelper.idle()
        
        // Check if numeric keyboard
        for number in 0...9 {
            XCTAssertTrue(app.keyboards.firstMatch.keys.element(matching: .key, identifier: String(number)).exists)
        }
        
        // Enter correct passcode
        app.secureTextFields["passcode"].typeText(SetupFlowHelper.correctPasscode)
        HumanDelayHelper.idle() 
        
        // Main password screen must be visible after entering correct passcode
        XCTAssertTrue(app.otherElements["mainPasswords"].exists)
    }
    
    func testSignInInvalidPasscode() {
        SetupFlowHelper.forwardToMain(app)
        
        // Terminate & launch app again
        app.launchArguments = ["--DisableBiometrics"]
        app.terminate()
        app.launch()
        
        HumanDelayHelper.idle()
        
        // Authentication screen must be visible after relaunch
        XCTAssertTrue(app.otherElements["authEntry"].exists)
        HumanDelayHelper.idle()
        
        // Enter incorrect passcode
        app.secureTextFields["passcode"].typeText(SetupFlowHelper.incorrectPasscode)
        
        // Authentication screen must be visible after incorrect passcode
        XCTAssertTrue(app.otherElements["authEntry"].exists)
    }
    
    func testSignInSettings() {
        SetupFlowHelper.forwardToMain(app)
        
        // Terminate & launch app again
        app.launchArguments = ["--DisableBiometrics"]
        app.terminate()
        app.launch()
        
        HumanDelayHelper.idle()
        
        // Tap settings button on lock screen
        _ = app.navigationBars.children(matching: .button).firstMatch.waitForExistence(timeout: 2)
        app.navigationBars.children(matching: .button).firstMatch.tap()
        
        // Sign out button must exist
        XCTAssertTrue(app.cells["miscSignOut"].exists)
    }
    
    func testSignOut() {
        AuthFlowHelper.forwardToSettingsTab(app)
        
        // Sign out button must be visible
        XCTAssertTrue(app.cells["miscSignOut"].exists)
        
        // Sign out button tap must show alert
        app.cells["miscSignOut"].tap()
        HumanDelayHelper.idle()
        XCTAssertEqual(app.alerts.count, 1)
        
        // Cancel must remain on same screen
        app.alerts.firstMatch.buttons.element(boundBy: 0).tap()
        HumanDelayHelper.idle()
        XCTAssertTrue(app.cells["miscSignOut"].exists)
        
        // Confirm button tap must sign out the user
        app.cells["miscSignOut"].tap()
        HumanDelayHelper.idle()
        app.alerts.firstMatch.buttons.element(boundBy: 1).tap()
        HumanDelayHelper.idle()
        XCTAssertFalse(app.cells["miscSignOut"].exists)
        
        // Welcome screen must be visible after sign out
        XCTAssertTrue(app.otherElements["setupWelcome"].exists)
    }
    
}
