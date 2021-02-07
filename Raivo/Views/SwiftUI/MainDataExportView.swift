//
//
// Raivo OTP
//
// Copyright (c) 2021 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/raivo-otp/ios-application/blob/master/LICENSE.md
//

import SwiftUI

struct MainDataExportView: View {
    
    @State(initialValue: false) var busy: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10, content: {
                
                Spacer()
                
                Text("The export is an AES-encrypted ZIP archive, so make sure you use the right tools when extracting it.")
                
                Text("Some archive utilities may not be able to extract AES encrypted ZIP files. ").bold()
                
                Text("The archivers below are known to have AES encryption support.")
                
                Divider()
                
                Button("The Unarchiver (for MacOS)") {
                    
                }
                
                Button("7-Zip (for Windows)") {
                    
                }
                
                Divider()
                
                Spacer()
                
                FilledButton(busy ? "Exporting..." : "Export", busy: $busy) {
                    busy = true
                }
                
            })
                .padding(10)
                .navigationBarTitle("Export")
        }
    }
}

struct MainDataExportView_Previews: PreviewProvider {
    static var previews: some View {
        MainDataExportView()
    }
}
