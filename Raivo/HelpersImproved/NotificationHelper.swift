//
//  NotificationHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 24/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

class NotificationHelper {
    
    public static let shared = NotificationHelper()
    
    private var singleInstances: [String: NSObjectProtocol] = [:]
    
    private init() {
    
    }
    
    public func listen(to: Notification.Name, distinctBy: String, _ callback: @escaping (() -> Void)) {
        let key = to.rawValue + distinctBy
        
        if singleInstances.keys.contains(key) {
            NotificationCenter.default.removeObserver(singleInstances[key]!)
        }
        
        singleInstances[key] = NotificationCenter.default.addObserver(forName: to, object: nil, queue: nil) { note in
            callback()
        }
    }
    
    public func listenOnce(to: Notification.Name, _ callback: @escaping (() -> Void)) {
        var observer: NSObjectProtocol? = nil
        
        observer = NotificationCenter.default.addObserver(forName: to, object: nil, queue: nil) { note in
            NotificationCenter.default.removeObserver(observer!)
            callback()
        }
    }
    
}
