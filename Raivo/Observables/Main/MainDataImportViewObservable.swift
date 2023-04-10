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
import Combine

final class MainDataImportViewObservable: ObservableObject {
    
    @Published var busy = false
    
    @Published var present = false
    
    @Published var archive: URL? = nil
}
