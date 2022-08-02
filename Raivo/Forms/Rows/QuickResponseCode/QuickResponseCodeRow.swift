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
import Eureka

final class QuickResponseCodeRow: Row<QuickResponseCodeRowCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<QuickResponseCodeRowCell>(nibName: "QuickResponseCodeRowCell", bundle: Bundle.main)
    }
    
}
