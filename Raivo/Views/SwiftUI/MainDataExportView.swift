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
    
    @ObservedObject var mainDataExport: MainDataExportViewObservable
        
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10, content: {
                
                Spacer()
                
                Group {
                
                    Text("Use one of the utilities below to extract your AES-encrypted ZIP archive, as these are known for their AES-encryption support.")
                    
                    Divider()
                    
                    Text("The Unarchiver (for MacOS)").bold()
                    
                    Button("theunarchiver.com") {
                        UIApplication.shared.open(URL(string: "https://theunarchiver.com/")!)
                    }
                    
                    Text("7-Zip (For Windows)").bold()
                    
                    Button("7-zip.org") {
                        UIApplication.shared.open(URL(string: "https://www.7-zip.org/")!)
                    }
                    
                    Divider()
                    
                    Text("Use your master password (without passcode) to decrypt the archive.")
                    
                }
                
                Spacer()
                
                FilledButton(mainDataExport.busy ? "Exporting..." : "Export", busy: $mainDataExport.busy) {
                    BannerHelper.shared.done("Hold tight", "Generation takes a few seconds")
                    mainDataExport.export()
                }
                
            })
                .padding()
                .navigationBarHidden(true)
                .sheet(isPresented: $mainDataExport.present, onDismiss: {
                    mainDataExport.present = false
                    mainDataExport.busy = false
                }, content: {
                    ActivityViewController(activityItems: [mainDataExport.archive!])
                })
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        
    }

}

struct MainDataExportView_Previews: PreviewProvider {
    static var previews: some View {
        MainDataExportView(mainDataExport: MainDataExportViewObservable())
    }
}
