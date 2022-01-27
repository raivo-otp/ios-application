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

/// A view for 'help' with exporting your passwords
struct MainDataExportView: View {
    
    /// An observable that contains the variable content of the view
    @ObservedObject var mainDataExport: MainDataExportViewObservable
    
    /// The body of the view
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10, content: {
                Spacer()
                Group {
                    Text("You can use one of the utilities below to extract your encrypted ZIP archive.")
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
                .sheet(isPresented: $mainDataExport.present) {
                    ActivityViewController(activityItems: [mainDataExport.archive!])
                }
        }
    }
}

/// A controller that displays a sharing sheet (for example share to AirDrop, or save to files)
struct ActivityViewController: UIViewControllerRepresentable {

    /// An (initially) empty array of items to share
    var activityItems: [Any]
    
    /// Creates the view controller object and configures its initial state.
    ///
    /// - Parameter context: A context structure containing information about the current state of the system.
    /// - Returns: A UIKit view controller configured with the provided information.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    /// Updates the state of the specified view controller with new information from SwiftUI.
    ///
    /// - Parameters:
    ///   - uiViewController: A custom view controller object.
    ///   - context: A context structure containing information about the current state of the system.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        // Not implemented
    }

}

/// A preview for the data export view
struct MainDataExportView_Previews: PreviewProvider {
    static var previews: some View {
        MainDataExportView(mainDataExport: MainDataExportViewObservable())
    }
}
