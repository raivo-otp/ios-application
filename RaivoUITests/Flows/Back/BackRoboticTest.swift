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

class BackRoboticTest: XCTestCase {
    
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
    
    func testBackStoryboard() {
        SetupFlowHelper.forwardToMain(app)
        
        // Main storyboard must be visible on start
        XCTAssertTrue(app.otherElements["mainPasswords"].exists)
        XCTAssertEqual(app.state, .runningForeground)
        
        // Move app to background
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        HumanDelayHelper.idle(3)
        
        // Ensure app is in background
        XCTAssertNotEqual(app.state, .runningForeground)
        let backgroundTime = Date()
        
        // Start timer to move app to the foreground after 2 seconds
        let _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(2.5), repeats: false, block: { timer in
            self.app.activate()
        })
        
        // Check if app is in the background, and wait on the 'to foreground' move
        XCTAssertNotEqual(app.state, .runningForeground)
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 4))
        
        // At least 2 seconds should have past
        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(backgroundTime), 2)
        
        // Main storyboard must be visible after move to foreground
        HumanDelayHelper.idle(2)
        XCTAssertTrue(app.otherElements["mainPasswords"].exists)
    }
    
}
