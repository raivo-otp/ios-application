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
    
    @IBOutlet weak var nextButton: UIButton!
    
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
    
    @IBAction func onNext(_ sender: Any) {
        let realm = try! Realm()
        
        try! realm.write {
            password!.counter += 1
            password!.syncing = true
            password!.synced = false
        }
        
        currentPassword.text = TokenHelper.formatPassword(password!.getToken(true))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = nextButton.backgroundColor
        super.setSelected(selected, animated: animated)

        if selected {
            nextButton.backgroundColor = color
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = nextButton.backgroundColor
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            nextButton.backgroundColor = color
        }
    }
    
}
