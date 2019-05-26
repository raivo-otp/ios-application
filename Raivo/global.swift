//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
//

import SwiftyBeaver

/// Global reference to the SwiftyBeaver logging framework
let log = SwiftyBeaver.self

/// Get the Application Principal (shared `UIApplication` class).
///
/// - Returns: The application principal singleton instance
func getAppPrincipal() -> ApplicationPrincipal {
    return (ApplicationPrincipal.shared as! ApplicationPrincipal)
}

/// Get the Application Delegate (shared `UIApplicationDelegate` class).
///
/// - Returns: The application delegate singleton instance
func getAppDelegate() -> ApplicationDelegate {
    return (getAppPrincipal().delegate as! ApplicationDelegate)
}

/// Return a uniquely identifiable string (ID) for the given class.
///
/// - Parameter reference: The class or object to describe
/// - Returns: A string describing the class (e.g. `com.finnwea.raivo.StorageHelper`)
func id(_ reference: Any) -> String {
    return AppHelper.identifier + String(describing: reference).split(separator: ".").last!
}
