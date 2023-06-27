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

import Foundation
import EFQRCode
import UIKit
import SDWebImage

class TimeBasedPasswordCell: PasswordCell {
    
    var password: Password?
    
    var stateTimer: Timer?
    
    var isAnimating: Bool = false
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var issuer: UILabel!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var currentPassword: UILabel!
    
    @IBOutlet weak var previousPassword: UILabel!
    
    @IBOutlet weak var passwordDelimiter: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var notSyncedView: UIImageView!
    
    @IBOutlet weak var syncingView: UIActivityIndicatorView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updatePreviousPassword(_ password: Password) {
        previousPassword.text = TokenHelper.shared.formatPassword(password.getToken(), previous: true)
        
        if StorageHelper.shared.getPreviousPasswordEnabled() {
            previousPassword.isHidden = false
            passwordDelimiter.isHidden = false
        } else {
            previousPassword.isHidden = true
            passwordDelimiter.isHidden = true
        }
    }
    
    override internal func setPassword(_ password: Password) {
        self.password = password
        
        let pinned = password.pinned ? "• " : ""
        issuer.text = pinned + password.issuer
        account.text = password.account.count > 0 ? "(" + password.account + ")" : ""
        currentPassword.text = TokenHelper.shared.formatPassword(password.getToken())
        updatePreviousPassword(password)
        
        notSyncedView.isHidden = password.synced || password.syncing
        syncingView.isHidden = password.synced || !password.syncing
        (!password.synced && password.syncing) ? syncingView.startAnimating() : syncingView.stopAnimating()
        
        progressView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        traitCollectionDidChange(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        icon.sd_setImage(
            with: password?.getIconURL(),
            placeholderImage: UIImage(named: "vector-empty-item"),
            context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
        )
    }
    
    deinit {
        stateTimer?.invalidate()
    }
    
    override internal func updateState(force: Bool = false) {
        guard let password = password, !password.isInvalidated else {
            return
        }
        
        if isAnimating && !force {
            return
        }
        
        self.isAnimating = true
        stateTimer?.invalidate()
        
        currentPassword.text = TokenHelper.shared.formatPassword(password.getToken())
        updatePreviousPassword(password)
        
        notSyncedView.isHidden = password.synced || password.syncing
        syncingView.isHidden = password.synced || !password.syncing
        (!password.synced && password.syncing) ? syncingView.startAnimating() : syncingView.stopAnimating()
        
        let timer = TimeInterval(password.timer)
        let epoch = Date().timeIntervalSince1970

        let from = TimeInterval(UInt64(epoch / timer)) * timer
        let to = Date(timeIntervalSince1970: from + timer)
        
        let remain = from + timer - epoch
        
        let progress = 1 - (100 / Float(timer) * Float(remain) / 100)
        
        self.progressView.setProgress(progress, animated: false)
        self.progressView.layoutIfNeeded()
        
        stateTimer = Timer.init(fire: to, interval: 0, repeats: false) { timer in
            self.isAnimating = false
            self.updateState()
        }
        
        if let stateTimer = stateTimer {
            RunLoop.current.add(stateTimer, forMode: .default)
        }
                
        // Remove old animations (otherwise the progress bar goes further than 100%, which is a bug)
        // https://stackoverflow.com/questions/44397720/swift-progress-view-animation-makes-the-bar-go-further-than-100
        self.progressView.layer.sublayers?.forEach { $0.removeAllAnimations() }
        
        self.progressView.setProgress(1, animated: false)
        UIView.animate(withDuration: remain, delay: 0, options: .curveLinear, animations: {
            self.progressView.layoutIfNeeded()
        })
    }
    
}
