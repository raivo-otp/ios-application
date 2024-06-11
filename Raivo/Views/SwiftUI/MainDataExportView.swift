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
                    Text("Please read the following notice carefully!").bold()
                    Divider()
                    Text("Your ZIP-archive is encrypted using your master password (without passcode).")
                    Divider()
                    Text("If your master password contains special characters, third-party unzip utilities might not be able to decrypt it. If your unzip utility does not support AES-encryption, it will not be able to decrypt the ZIP-export either.")
                    Divider()
                    Text("If you're having trouble decrypting your ZIP-export, try to decrypt it via the iOS/iPadOS files application itself.")
                }
                Spacer()
                FilledButtonText(mainDataExport.busy ? "Exporting..." : "Export", busy: $mainDataExport.busy) {
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
        .navigationViewStyle(StackNavigationViewStyle())
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
