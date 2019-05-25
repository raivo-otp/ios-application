//
//  MyApplication
//  Raivo
//
//  Created by Tijme Gommers on 07/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit

class MyApplication: UIApplication {
    
    private var inactivityTimerEnabled = false
    
    private var inactivityTimer: Timer?
    
    private var inactivityTimeout: TimeInterval = 120
    
    func enableInactivityTimer() {
        inactivityTimerEnabled = true
        scheduleInactivityTimer()
    }
    
    func disableInactivityTimer() {
        inactivityTimerEnabled = false
    }
   
    override func sendEvent(_ event: UIEvent) {
        guard event.type == .touches else {
            return super.sendEvent(event)
        }
        
        var restartTimer = true
        
        if let touches = event.allTouches {
            // At least one touch in progress? Do not restart timer, just invalidate it
            for touch in touches.enumerated() {
                if touch.element.phase != .cancelled && touch.element.phase != .ended {
                    restartTimer = false
                    break
                }
            }
        }
        
        if restartTimer {
            scheduleInactivityTimer()
        } else {
            invalidateInactivityTimer()
        }
        
        super.sendEvent(event)
    }
    
    public func scheduleInactivityTimer() {
        guard inactivityTimerEnabled else {
            return
        }
        
        invalidateInactivityTimer()
        
        let inactivityTimeoutString = StorageHelper.shared.getLockscreenTimeout() ?? MiscellaneousInactivityLockFormOption.OPTION_DEFAULT.value
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityTimeoutString, repeats: false, block: { timer in
            guard self.inactivityTimerEnabled else {
                return
            }
            
            StateHelper.shared.lock()
        })
    }
    
    private func invalidateInactivityTimer() {
        inactivityTimer?.invalidate()
    }
    
}
