//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit
import SPStorkController

class StorkPopoverSegue: UIStoryboardSegue {
    
    public var transitioningDelegate: SPStorkTransitioningDelegate?
    
    override func perform() {
        transitioningDelegate = transitioningDelegate ?? SPStorkTransitioningDelegate()
        destination.transitioningDelegate = transitioningDelegate
        destination.modalPresentationStyle = .custom
        source.present(destination, animated: true, completion: nil)
    }
    
}
