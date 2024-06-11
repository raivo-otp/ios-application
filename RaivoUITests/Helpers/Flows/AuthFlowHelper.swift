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

class AuthFlowHelper {
    
    static func forwardToSettingsTab(_ app: XCUIApplication) {
        SetupFlowHelper.forwardToMain(app)
        
        let _ = app.tabBars.buttons.element(boundBy: 2).waitForExistence(timeout: 2)
        app.tabBars.buttons.element(boundBy: 2).tap()
        
        HumanDelayHelper.idle()
    }

}
