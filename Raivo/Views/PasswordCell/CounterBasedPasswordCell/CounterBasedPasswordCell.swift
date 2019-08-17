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
        currentPassword.text = TokenHelper.formatPassword(password.getToken())
        notSyncedView.isHidden = password.synced || password.syncing
        
        icon.sd_setImage(with: password.getIconURL(), placeholderImage: UIImage(named: "password-placeholder"))
        icon.image = icon.image?.withIconEffect
    }
    
    override internal func updateState(force: Bool = false) {
        guard !password!.isInvalidated else {
            return
        }
        
        currentPassword.text = TokenHelper.formatPassword(password!.getToken())
        notSyncedView.isHidden = password!.synced || password!.syncing
    }
    
}
