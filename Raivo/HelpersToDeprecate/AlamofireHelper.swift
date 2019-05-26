//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import Alamofire

class AlamofireHelper {
    
    static func manager(withoutCache: Bool = false) -> SessionManager {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["User-Agent"] = AppHelper.userAgent
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        if withoutCache {
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        }
        
        return Alamofire.SessionManager(configuration: configuration)
    }
    
}
