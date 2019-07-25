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
import UIKit

/// A UIDigitField represents a single digit that can be entered in a UIPincodeField
class UIDigitField: UIView, UITextFieldDelegate {
    
    /// The color of the digit
    private let color: UIColor = .black
    
    /// The frame for an empty value
    private var dashFrame: CGRect? = nil
    
    /// The view for an empty value
    private var dashView: UIView? = nil

    /// The frame width for an empty value
    private var dashWidth: CGFloat = 20

    /// The frame height for an empty value
    private var dashHeight: CGFloat = 4
    
    /// The frame for a non-empty value
    private var circleFrame: CGRect? = nil
    
    /// THe view for a non-empty value
    private var circleView: UIView? = nil
    
    /// The frame width for a non-empty value
    private var circleWidth: CGFloat = 20
    
    /// The frame height for a non-empty value
    private var circleHeight: CGFloat = 20

    /// The value that was entered
    public var value: Int? = nil {
        didSet {
            updateView()
        }
    }
    
    /// Initialize the current UIView using a size.
    /// A frame will be initiated from this size.
    ///
    /// - Parameter frame: The frame to use
    public convenience init(size: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        circleWidth = size
        circleHeight = size
        dashWidth = size
        
        commonInit()
    }
    
    /// Initialize the current UIView using a frame
    ///
    /// - Parameter frame: The frame to use
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Initialzie the current UIView using a coder
    ///
    /// - Parameter aDecoder: The coder to use
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// A function that is ran by all public initializers
    private func commonInit() {
        updateView()
    }
    
    /// Adjust all of the subviews to the new parent dimensions
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        layoutDashIfNeeded()
        layoutCircleIfNeeded()
    }
    
    /// Update the view based on its value and state
    private func updateView() {
        value != nil ? showCircle() : showDash()
        
        layoutIfNeeded()
    }
    
    /// Show a dash (used if the value is empty)
    private func showDash() {
        if dashView == nil {
            dashView = UIView()
            dashView?.backgroundColor = color
            
            addSubview(dashView!)
        }
        
        layoutCircleIfNeeded()
        
        animate(show: dashView, hide: circleView)
    }
    
    /// Adjust the dash to the options/dimensions in use
    private func layoutDashIfNeeded() {
        let positionX = (layer.bounds.width - dashWidth) / 2
        let positionY = (layer.bounds.height - dashHeight) / 2
        
        dashFrame = CGRect(x: positionX, y: positionY, width: dashWidth, height: dashHeight)
        dashView?.frame = dashFrame!
    }
    
    /// Show a circle (used if the value is non-empty)
    private func showCircle() {
        if circleView == nil {
            circleView = UIView()
            circleView?.backgroundColor = color
            circleView?.layer.cornerRadius = circleWidth / 2 
            circleView?.layer.masksToBounds = true
            
            addSubview(circleView!)
        }
        
        layoutCircleIfNeeded()
        
        animate(show: circleView, hide: dashView)
    }
    
    /// Adjust the circle to the options/dimensions in use
    private func layoutCircleIfNeeded() {
        let positionX = (layer.bounds.width - circleWidth) / 2
        let positionY = (layer.bounds.height - circleHeight) / 2
        
        circleFrame = CGRect(x: positionX, y: positionY, width: circleWidth, height: circleHeight)
        circleView?.frame = circleFrame!
    }
    
    /// Animate the change from dash to circle (or the other way around)
    ///
    /// - Parameter show: Which view to show
    /// - Parameter hide: Which view to hide
    private func animate(show: UIView?, hide: UIView?) {
        UIView.animate(withDuration: 0.2, animations: {
            show?.alpha = 1.0
            hide?.alpha = 0.0
        }, completion: nil)
    }
    
}
