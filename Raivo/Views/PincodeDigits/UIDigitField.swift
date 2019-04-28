//
//  UIDigitField.swift
//  Raivo
//
//  Created by Tijme Gommers on 02/02/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
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
