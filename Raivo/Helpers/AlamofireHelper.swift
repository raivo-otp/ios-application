//
//  AlamofireHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 12/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
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
