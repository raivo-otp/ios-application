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

protocol UIDigitFieldDelegate {
    func digitBackspace()
}

class UIDigitField: UITextField {
    
    override var bounds: CGRect {
        didSet {
            self.evaluateView()
        }
    }
    
    var controlDelegate: UIDigitFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.evaluateView()
    }
        
    public func evaluateView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        controlDelegate?.digitBackspace()
    }
    
}
