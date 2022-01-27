//
// Raivo OTP
//
// Copyright (c) 2022 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import UIKit
import RealmSwift

class CounterBasedPasswordCell: PasswordCell {
    
    var password: Password?
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var issuer: UILabel!
    
    @IBOutlet weak var account: UILabel!
    
    @IBOutlet weak var currentPassword: UILabel!
    
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
        account.text = password.account.count > 0 ? "(" + password.account + ")" : ""
        currentPassword.text = TokenHelper.shared.formatPassword(password.getToken())
        notSyncedView.isHidden = password.synced || password.syncing
        
        traitCollectionDidChange(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        icon.sd_setImage(
            with: password?.getIconURL(),
            placeholderImage: UIImage(named: "vector-empty-item"),
            context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
        )
    }
    
    override internal func updateState(force: Bool = false) {
        guard !password!.isInvalidated else {
            return
        }
        
        currentPassword.text = TokenHelper.shared.formatPassword(password!.getToken())
        notSyncedView.isHidden = password!.synced || password!.syncing
    }
    
}
