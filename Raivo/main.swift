//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit

/// Create the event lifecycle using the application principal and delegate.
/// 
/// - Note: Specifications:
///         https://developer.apple.com/documentation/uikit/1622933-uiapplicationmain
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(ApplicationPrincipal.self),
    NSStringFromClass(ApplicationDelegate.self)
)
