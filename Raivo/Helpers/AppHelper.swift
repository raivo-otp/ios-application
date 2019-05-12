//
//  AppHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 26/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class AppHelper {
    
    /// The main bundle identifier (e.g. com.apple.mainapp).
    ///
    /// - note: Our identifier cannot be nil since it's hardcoded in the 'info.plist' file
    public static let identifier = Bundle.main.bundleIdentifier!
    
    /// The main bundle build number (e.g. 1, 2 or 3).
    ///
    /// - note: Our build number cannot be nil since it's hardcoded in the 'info.plist' file
    public static let build = Int(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
    
    /// The main bundle human version representation (e.g. 3.4.1).
    ///
    /// - note: Our version cannot be nil since it's hardcoded in the 'info.plist' file
    public static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
 
    /// The main bundle compilation method (e.g. 'Debug' or 'Release').
    ///
    /// - note: The App Store receipt URL ends with "sandboxReceipt" if installed via TestFlight
    #if DEBUG
    public static let compilation = "Debug"
    #else
    public static let compilation =  Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : "Release"
    #endif
    
    /// The domain (including directory) that hosts the custom issuer icons
    ///
    /// - todo: Convert this to a Content Delivery Network (CDN).
    public static let iconsURL = "https://raw.finnwea.com/raivo-issuer-icons/dist/"
    
    /// User agent for HTTP requests (e.g. searching icons)
    public static let userAgent = identifier + "/" + version
    
}
