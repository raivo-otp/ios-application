//
//  PincodeDigitsView
//  Raivo
//
//  Created by Tijme Gommers on 02/02/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Spring

class PincodeDigitsView: UIView, UITextFieldDelegate, UIDigitFieldDelegate {
    
    private var biometrics = false
    
    weak var delegate: PincodeDigitsProtocol?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var digit1: UIDigitField!
    @IBOutlet weak var digit2: UIDigitField!
    @IBOutlet weak var digit3: UIDigitField!
    @IBOutlet weak var digit4: UIDigitField!
    @IBOutlet weak var digit5: UIDigitField!
    @IBOutlet weak var digit6: UIDigitField!
    
    var digitComplete = UIDigitField()
    
    var currentDigit = 1
    
    var digitFields = [UIDigitField]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func showBiometrics(_ show: Bool = true) {
        biometrics = show
        commonInit()
    }
    
    public func reset() {
        self.currentDigit = 1
        
        for (index, digitField) in self.digitFields.enumerated() {
            digitField.text = ""
            digitField.isEnabled = index == 0
        }
    }
    
    public func focus() {
        self.digit1.becomeFirstResponder()
    }
    
    public func resetAndFocus() {
        DispatchQueue.main.async {
            self.reset()
            self.focus()
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(biometrics ? "PincodeDigitsViewBiometrics" : "PincodeDigitsView", owner: self, options: nil)
        
        self.subviews.first?.removeFromSuperview()
        self.addSubview(self.contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        digitFields.removeAll()
        
        digitFields.append(digit1)
        digit1.controlDelegate = self;
        digit1.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digit2)
        digit2.controlDelegate = self;
        digit2.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digit3)
        digit3.controlDelegate = self;
        digit3.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digit4)
        digit4.controlDelegate = self;
        digit4.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digit5)
        digit5.controlDelegate = self;
        digit5.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digit6)
        digit6.controlDelegate = self;
        digit6.addTarget(self, action: #selector(digitChanged(_:)), for: .editingChanged)
        
        digitFields.append(digitComplete)

        if !isHidden {
            reset()
        }
    }
    
    private func focusOnPrevDigit() {
        if (currentDigit != 1) {
            currentDigit -= 1
            digitFields[currentDigit - 1].isEnabled = true
            digitFields[currentDigit - 1].becomeFirstResponder()
            digitFields[currentDigit].isEnabled = false
        }
    }

    private func focusOnNextDigit() {
        if (currentDigit == 6) {
            digitFields[currentDigit - 1].isEnabled = false
            self.allDigitsEntered()
        } else {
            currentDigit += 1
            digitFields[currentDigit - 1].isEnabled = true
            digitFields[currentDigit - 1].becomeFirstResponder()
            digitFields[currentDigit - 2].isEnabled = false
        }
    }
    
    private func allDigitsEntered() {
        var pincode = self.digit1.text!
        pincode += self.digit2.text!
        pincode += self.digit3.text!
        pincode += self.digit4.text!
        pincode += self.digit5.text!
        pincode += self.digit6.text!
        
        DispatchQueue.global(qos: .background).async {
            self.delegate?.onPincodeComplete(pincode: pincode)
        }
    }
    
    func digitBackspace() {
        self.focusOnPrevDigit()
        digitFields[currentDigit - 1].text = ""
    }
    
    @objc func digitChanged(_ textField: UITextField) {
        if let digit = textField.text {
            if (digit.count == 0) {
                self.focusOnPrevDigit()
            } else {
                self.focusOnNextDigit()
            }
        }
    }
    
    @IBAction func onBiometricsInitiate(_ sender: Any) {
        delegate?.onBiometricsTrigger()
    }
}
