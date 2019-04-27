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
    
}
