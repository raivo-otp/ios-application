//
//  NotificationHelper.swift
//  Raivo
//
//  Created by Tijme Gommers on 24/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation

/// A helper class for managing notifications/observers
///
/// Listen once
/// -----------
///
///     NotificationHelper.shared.listenOnce(to: .CKAccountChanged, {
///         print("iCloud account changed")
///     })
///
/// Listen and stop old listeners
/// -----------------------------
///
/// You can place this in e.g. a viewDidAppear method, and even though the listen method could be called
/// multiple times, it will only trigger once.
///
///     NotificationHelper.shared.listen(to: .CKAccountChanged, distinctBy: "AccountView") {
///         print("iCloud account changed")
///     }
///
class NotificationHelper {

    /// The singleton instance for the NotificationHelper
    public static let shared = NotificationHelper()

    /// Keeps track of observers for notifications that only one observer may listen to
    private var singleInstances: [String: NSObjectProtocol] = [:]

    /// A private initializer to make sure this class can only be used as a singleton class
    private init() {}

    /// Observe a notification and stop the old listeners observing this notification
    ///
    /// - Parameter to: Which notification to listen to
    /// - Parameter distinctBy: Overwrite previous listeners with this name, to allow only one observer instance
    /// - Parameter callback: A closure that is called when the notification is observed
    public func listen(to: Notification.Name, distinctBy: String, _ callback: @escaping (() -> Void)) {
        let key = to.rawValue + distinctBy
        
        if singleInstances.keys.contains(key) {
            NotificationCenter.default.removeObserver(singleInstances[key]!)
        }
        
        singleInstances[key] = NotificationCenter.default.addObserver(forName: to, object: nil, queue: nil) { note in
            callback()
        }
    }

    /// Stop observing a notification that you're listening to
    ///
    /// - Parameter notification: Which notification to stop listening to
    /// - Parameter byDistinctName: The identifiable observer name to stop
    public func discard(_ notification: Notification.Name, byDistinctName: String) {
        let key = notification.rawValue + byDistinctName
        
        if singleInstances.keys.contains(key) {
            NotificationCenter.default.removeObserver(singleInstances[key]!)
        }
    }

    /// Observe a notification only once, then stop listening
    ///
    /// - Parameter to: Which notification to listen to
    /// - Parameter callback: A closure that is called when the notification is observed
    public func listenOnce(to: Notification.Name, _ callback: @escaping (() -> Void)) {
        var observer: NSObjectProtocol? = nil
        
        observer = NotificationCenter.default.addObserver(forName: to, object: nil, queue: nil) { note in
            NotificationCenter.default.removeObserver(observer!)
            callback()
        }
    }

}
