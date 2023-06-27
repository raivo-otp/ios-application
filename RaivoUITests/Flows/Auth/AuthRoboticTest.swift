//
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
        XCTAssertGreaterThanOrEqual(app.keyboards.firstMatch.keys.count, 10)
        XCTAssertLessThan(app.keyboards.firstMatch.keys.count, 15)
        
        // Enter incorrect passcode
        app.secureTextFields["passcode"].typeText(SetupFlowHelper.incorrectPasscode)
        HumanDelayHelper.idle()
        
        // Authentication screen must be visible after incorrect passcode
        XCTAssertTrue(app.otherElements["authEntry"].exists)
    }
    
    func testSignInInvalidPasscode() {
        SetupFlowHelper.forwardToMain(app)
        
        // Terminate & launch app again
        app.launchArguments = ["--DisableBiometrics"]
        app.terminate()
        app.launch()
        
        HumanDelayHelper.idle()
        
        // Authentication screen must be visible after relaunch
        let authEntry = app.otherElements["authEntry"]
        XCTAssertTrue(authEntry.exists)
        HumanDelayHelper.idle()
        
        // Enter incorrect passcode
        app.secureTextFields["passwordConfirmation"].tap()
        app.secureTextFields["passwordConfirmation"].typeText("BBBBBBBBBB")
        
        let setupPasswordInitial = app.otherElements["setupPasswordInitial"]
        XCTAssertTrue(setupPasswordInitial.exists)
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
        let signOut = app.cells["miscSignOut"]
        XCTAssertTrue(signOut.exists)
    }
    
    func testSignOut() {
        AuthFlowHelper.forwardToSettingsTab(app)
        
        // Sign out button must be visible
        let signOutButton = app.cells["miscSignOut"]
        XCTAssertTrue(signOutButton.exists)
        
        // Sign out button tap must show alert
        signOutButton.tap()
        HumanDelayHelper.idle()
        XCTAssertEqual(app.alerts.count, 1)
        
        // Cancel must remain on same screen
        app.alerts.firstMatch.buttons.element(boundBy: 0).tap()
        HumanDelayHelper.idle()
        XCTAssertTrue(signOutButton.exists)
        
        // Confirm button tap must sign out the user
        signOutButton.tap()
        HumanDelayHelper.idle()
        app.alerts.firstMatch.buttons.element(boundBy: 1).tap()
        HumanDelayHelper.idle()
        XCTAssertFalse(signOutButton.exists)
        
        // Welcome screen must be visible after sign out
        let setupWelcome = app.otherElements["setupWelcome"]
        XCTAssertTrue(setupWelcome.exists)
    }
    
}
