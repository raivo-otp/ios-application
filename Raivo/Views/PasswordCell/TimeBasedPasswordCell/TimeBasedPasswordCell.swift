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
import EFQRCode
import UIKit

class TimeBasedPasswordCell: PasswordCell {
    
    var password:Password?
    
    var stateTimer:Timer?
    
    var isAnimating:Bool = false
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var issuer: UILabel!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var currentPassword: UILabel!
    
    @IBOutlet weak var previousPassword: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var notSyncedView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override internal func setPassword(_ password: Password) {
        self.password = password
        
        issuer.text = password.issuer
        account.text = "(" + password.account + ")"
        currentPassword.text = TokenHelper.formatPassword(password.getToken())
        previousPassword.text = TokenHelper.formatPassword(password.getToken(), previous: true)
        notSyncedView.isHidden = password.synced || password.syncing
      
        icon.sd_setImage(with: password.getIconURL(), placeholderImage: UIImage(named: "password-placeholder"))
        icon.image = icon.image?.withIconEffect
    }
    
    deinit {
        stateTimer?.invalidate()
    }
    
    override internal func updateState(force: Bool = false) {
        if password!.isInvalidated || (isAnimating && !force) {
            return
        }
        
        self.isAnimating = true
        stateTimer?.invalidate()
        
        currentPassword.text = TokenHelper.formatPassword(password!.getToken())
        previousPassword.text = TokenHelper.formatPassword(password!.getToken(), previous: true)
        notSyncedView.isHidden = password!.synced || password!.syncing
        
        let timer = TimeInterval(password!.timer)
        let epoch = Date().timeIntervalSince1970
        
        let from = TimeInterval(UInt64(epoch / timer)) * timer
        let to = Date(timeIntervalSince1970: from + timer)
        let remain = from + timer - epoch
        
        let progress = 100 / Float(timer) * Float(remain) / 100
        
        self.progressView.setProgress(progress, animated: false)
        self.progressView.layoutIfNeeded()
        
        stateTimer = Timer.init(fire: to, interval: 0, repeats: false) { timer in
            self.isAnimating = false
            self.updateState()
        }
        
        RunLoop.current.add(stateTimer!, forMode: .default)
        
        // Remove old animations (otherwise the progress bar goes further than 100%, which is a bug)
        // https://stackoverflow.com/questions/44397720/swift-progress-view-animation-makes-the-bar-go-further-than-100
        self.progressView.layer.sublayers?.forEach { $0.removeAllAnimations() }
        self.progressView.setProgress(0, animated: false)
        UIView.animate(withDuration: remain, delay: 0, options: .curveLinear, animations: {
            self.progressView.layoutIfNeeded()
        })
    }
    
}
