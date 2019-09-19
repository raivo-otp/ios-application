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

import Foundation
import SwiftyBeaver

/// A helper class for general application information
class AppHelper {
    
    /// The available compilation types
    public struct Compilation {
        public static let debug = "Debug"
        public static let testFlight = "TestFlight"
        public static let release = "Release"
    }
    
    /// The main bundle identifier (e.g. com.apple.mainapp). This can vary for every compilation type.
    ///
    /// - Note: Our identifier cannot be nil since it's hardcoded in the 'info.plist' file
    public static let identifier = Bundle.main.bundleIdentifier!
    
    /// The release bundle identifier (e.g. com.apple.mainapp).
    public static let releaseIdentifier = "com.finnwea.Raivo"
    
    /// The main bundle build number (e.g. 1, 2 or 3).
    ///
    /// - Note: Our build number cannot be nil since it's hardcoded in the 'info.plist' file
    public static let build = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
    
    /// The main bundle human version representation (e.g. 3.4.1).
    ///
    /// - Note: Our version cannot be nil since it's hardcoded in the 'info.plist' file
    public static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
 
    /// The main bundle compilation method (e.g. 'Debug' or 'Release').
    ///
    /// - Note: The App Store receipt URL ends with "sandboxReceipt" if installed via TestFlight
    #if DEBUG
    public static let compilation = Compilation.debug
    #else
    public static let compilation = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? Compilation.testFlight : Compilation.release
    #endif
    
    /// The minimum level to log to the SwiftyBeaver destination
    public static let logLevel = (compilation == Compilation.debug) ? log.Level.verbose : log.Level.verbose
    
    /// The path the the debug log file
    public static let logFile = FileDestination().logFileURL?.deletingLastPathComponent().appendingPathComponent("raivo-debug-log.txt")
    
    /// The domain (including directory) that hosts the custom issuer icons
    ///
    /// - ToDo: Convert this to a Content Delivery Network (CDN).
    public static let iconsURL = "https://raw.finnwea.com/raivo-issuer-icons/dist/"
    
    /// User agent for HTTP requests (e.g. searching icons)
    public static let userAgent = identifier + "/" + version + " (" + compilation + ")"
    
}
