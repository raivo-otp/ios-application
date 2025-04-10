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

import UIKit
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

// The main data import process: a linear series of actions using UIKit
struct MainDataImportProcess: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: MainDataImportProcess
        let dataImport = DataImportFeature()
        
        init(_ parent: MainDataImportProcess) {
            self.parent = parent
        }
        
        // Present an alert on the root view
        private func doAlert(_ alertController: UIAlertController) {
            let viewController = UIApplication.shared.windows.first?.rootViewController
            viewController?.present(alertController, animated: true, completion: nil)
        }
        
        // The user selected a file: prompt them for a password
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let alertController = UIAlertController(title: "Enter password", message: "Please enter the password for decrypting the selected ZIP archive.", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default) { [ self] (action) in
                guard let selectedFileURL = urls.first, let password = alertController.textFields?[0].text else { return }
                
                // The user entered a password: attempt to import the archive, and report the outcome
                if let error = dataImport.importArchive(privateArchiveFileURL: selectedFileURL, withPassword: password) {
                    BannerHelper.shared.error("Import failed", error)
                } else {
                    BannerHelper.shared.done("Import succesful", "New OTPs were successfully imported from the ZIP archive")
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            doAlert(alertController)
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MainDataImportProcess>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.zip])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<MainDataImportProcess>) {
    }
    
    func makeCoordinator() -> MainDataImportProcess.Coordinator {
        return Coordinator(self)
    }
}

/// A view for 'help' with exporting your passwords
struct MainDataImportView: View {
    
    /// An observable that contains the variable content of the view
    @ObservedObject var mainDataImport: MainDataImportViewObservable
    
    @State private var isPresented = false
    
    /// The body of the view
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10, content: {
                Spacer()
                Group {
                    Text("Please read the following notice carefully!").bold()
                    Divider()
                    Text("The ZIP archive you select is assumed to be a backup previously exported from Raivo. You will be asked to provide a master password (without passcode), which may or may not differ from your current master password, to decrypt it.")
                    Divider()
                    Text("All imported OTP's will be added to Raivo (your existing OTP's will not be deleted.")
                    Divider()
                    Text("Your master password will not be changed.")
                }
                Spacer()
                FilledButtonText("Import") {
                    self.isPresented = true
                }.sheet(isPresented: $isPresented) {
                    MainDataImportProcess()
                }
            })
                .padding()
                .navigationBarHidden(true)
                .sheet(isPresented: $mainDataImport.present) {
                    ActivityViewController(activityItems: [mainDataImport.archive!])
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

/// A preview for the data import view
struct MainDataImportView_Previews: PreviewProvider {
    static var previews: some View {
        MainDataImportView(mainDataImport: MainDataImportViewObservable())
    }
}
