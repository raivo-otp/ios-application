//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit

/// Main entry point of the application
class ApplicationPrincipal: UIApplication {
    
    /// Positive if the inactivity timer is enabled (this is always true if the user entered his passcode)
    private var inactivityTimerEnabled = false
    
    /// A countdown timer that triggers the lockscreen if a certain threshold is met
    private var inactivityTimer: Timer?
    
    /// A date of the last user activity plus the inactivity time (can be used for locking the app while in the background)
    private var backgroundInactityDate: Date?
    
    /// Start observing application inactivity (and show the lockscreen if inactive)
    ///
    /// - Parameter schedule: If the inactivity timer needs to be scheduled right away.
    public func enableInactivityTimer(schedule: Bool = true) {
        inactivityTimerEnabled = true
        
        if schedule {
            scheduleInactivityTimer()
        }
    }
    
    /// Stop observing application inactivity (the lockscreen will not trigger anymore)
    public func disableInactivityTimer() {
        inactivityTimerEnabled = false
    }
    
    /// Listen for events that the user initiated, e.g. touches on the screen.
    ///
    /// - Parameter event: The event that triggered the listener
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if event.type == .touches {
            invalidateInactivityTimer()
        }
        
        if !eventHasActiveTouches(event) {
            scheduleInactivityTimer()
        }
    }
    
    /// Check if the given UIEvent contains ongoing touches.
    ///
    /// - Parameter event: The given UIEvent
    /// - Returns: Positive if the event has ongoing touches.
    private func eventHasActiveTouches(_ event: UIEvent) -> Bool {
        if let touches = event.allTouches {
            for touch in touches.enumerated() {
                if ![UITouch.Phase.cancelled, UITouch.Phase.ended].contains(touch.element.phase) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Schedule a timer that locks the app (goes to the lockscreen) if a certain threshold is met.
    public func scheduleInactivityTimer() {
        guard inactivityTimerEnabled else {
            return
        }
        
        invalidateInactivityTimer()
        
        let userLockscreenTimeout = StorageHelper.shared.getLockscreenTimeout()
        let defaultLockscreenTimeout = MiscellaneousInactivityLockFormOption.OPTION_DEFAULT.value
        let lockscreenTimeout = userLockscreenTimeout ?? defaultLockscreenTimeout
        
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: lockscreenTimeout, repeats: false, block: { timer in
            guard self.inactivityTimerEnabled else {
                return
            }
            
            StateHelper.shared.lock()
        })
    }
    
    /// Stop the active timer so the app won't move to the lockscreen
    private func invalidateInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    /// Tells the delegate that the app is about to become inactive.
    ///
    /// - Parameter application: The singleton app object.
    func applicationWillResignActive(_ application: UIApplication) {
        guard let inactivityTimer = inactivityTimer, inactivityTimer.isValid else {
            backgroundInactityDate = nil
            return
        }
        
        backgroundInactityDate = Date().addingTimeInterval(0 - Date().timeIntervalSince(inactivityTimer.fireDate))
        invalidateInactivityTimer()
    }
    
    /// Tells the delegate that the app has become active.
    ///
    /// - Parameter application: The singleton app object.
    func applicationDidBecomeActive(_ application: UIApplication) {
        let currentBackgroundInactityDate = backgroundInactityDate
        backgroundInactityDate = nil
        
        guard
            currentBackgroundInactityDate != nil,
            Date() >= currentBackgroundInactityDate!,
            inactivityTimerEnabled
        else {
            return
        }
        
        StateHelper.shared.lock(instant: true)
    }
    
    /// Open the given URL (by the native UIApplication.open handler
    override func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        super.open(url, options: options, completionHandler: completion)
    }
    
}
