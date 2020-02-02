//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import Alamofire

/// A helper class for Alamofire (e.g. session management)
class AlamofireHelper {
    
    /// The singleton instance for the AlamofireHelper
    public static let `default` = Alamofire.SessionManager(configuration: defaultConfiguration())
    
    /// The singleton instance for the AlamofireHelper
    public static let cacheless = Alamofire.SessionManager(configuration: cachelessConfiguration())
    
    /// Get the default URL session configuration for this application (with e.g. a custom user agent)
    ///
    /// - Returns: The session configuration to use in Alamofire
    private static func defaultConfiguration() -> URLSessionConfiguration {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["User-Agent"] = AppHelper.userAgent
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.timeoutIntervalForRequest = 8 // seconds
        configuration.timeoutIntervalForResource = 8 // seconds
        
        return configuration
    }
    
    /// Get a URL session configuration that doesn't cache requests/responses
    ///
    /// - Returns: The session configuration to use in Alamofire
    private static func cachelessConfiguration() -> URLSessionConfiguration {
        let configuration = defaultConfiguration()
        
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        return configuration
    }
    
}
