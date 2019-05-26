//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit

/// Main entry point of the application
class ApplicationPrincipal: UIApplication {
    
    /// Positive if the inactivity timer is enabled (this is always true if the user entered his PIN code)
    private var inactivityTimerEnabled = false
    
    /// A countdown timer that triggers the lockscreen if a certain threshold is met
    private var inactivityTimer: Timer?
    
    /// Start observing application inactivity (and show the lockscreen if inactive)
    public func enableInactivityTimer() {
        inactivityTimerEnabled = true
        scheduleInactivityTimer()
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
                    return false
                }
            }
        }
        
        return true
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
    }
    
}
