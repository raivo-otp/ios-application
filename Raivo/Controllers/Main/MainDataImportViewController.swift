//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved. 
//
// View the license that applies to the Raivo OTP source 
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit
import SwiftUI

class MainDataImportViewController: UIHostingController<MainDataImportView> {
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder, rootView: MainDataImportView(mainDataImport: MainDataImportViewObservable()))
    }

}
