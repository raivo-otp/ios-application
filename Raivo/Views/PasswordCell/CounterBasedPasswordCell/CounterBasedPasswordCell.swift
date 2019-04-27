//
//  CounterBasedPasswordCell.swift
//  Raivo
//
//  Created by Tijme Gommers on 10/04/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit

class CounterBasedPasswordCell: PasswordCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override internal func setPassword(_ password: Password) {
        //        cell.issuer?.text = results![row].issuer
        //        cell.account?.text = "(" + results![row].account + ")"
        //        cell.currentPassword?.text = TokenHelper.formatPassword(results![row].getToken())
        //        cell.previousPassword?.text = TokenHelper.formatPassword(results![row].getToken(), previous: true)
        //        cell.logo?.sd_setImage(with: nil, placeholderImage: UIImage(named: "password-placeholder"))
    }
    
    override internal func updateState(force: Bool = false) {
        
    }
    
}
