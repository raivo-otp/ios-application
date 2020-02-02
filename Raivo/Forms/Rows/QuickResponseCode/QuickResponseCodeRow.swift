//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
// 

import Foundation
import Eureka

final class QuickResponseCodeRow: Row<QuickResponseCodeRowCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<QuickResponseCodeRowCell>(nibName: "QuickResponseCodeRowCell", bundle: Bundle.main)
    }
    
}
