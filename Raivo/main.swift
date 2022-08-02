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

import UIKit

/// Create the event lifecycle using the application principal and delegate.
/// 
/// - Note Specifications:
///         https://developer.apple.com/documentation/uikit/1622933-uiapplicationmain
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(ApplicationPrincipal.self),
    NSStringFromClass(ApplicationDelegate.self)
)
