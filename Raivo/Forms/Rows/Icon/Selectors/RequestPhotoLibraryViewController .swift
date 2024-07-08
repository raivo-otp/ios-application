//
// Raivo OTP
//
// Copyright (c) 2024 Mobime. All rights reserved.
//
// View the license that applies to the Raivo OTP source
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import Foundation
import UIKit
import Photos

public class RequestPhotoLibraryViewController : UIViewController, ImagePickerModuleDelegate {
    
    
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var btnAllow: UIButton!

    var dismissCallback: ((UIImage?) -> Void)?
    var imagePicker: ImagePickerModule?
    weak var sender: UIViewController? = nil
    
    func set(dismissCallback: @escaping (UIImage?) -> Void) {
        self.dismissCallback = dismissCallback
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        initUI()
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true)
    }
    
    @IBAction func onBtnAllow(_ sender: Any) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        } else {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    let status = PHPhotoLibrary.authorizationStatus()
                    if status == .authorized || status == .limited {
                        self.startSelectingImage()
                    } else {
                        self.initUI()
                    }
                }
            }
        }
    }
    
    func initUI() {
        btnAllow.layer.cornerRadius = 10
        btnAllow.clipsToBounds = true
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied {
            lblSubTitle.text = "Raivo needs access to your photo library to enable custom icons. It is denied now. Do you want to go to settings to enable access?"
            btnAllow.setTitle("Go to settings", for: .normal)
        } else {
            lblSubTitle.text = "Raivo needs access to your photo library to enable custom icons. You can disable access from your device settings at any time."
            btnAllow.setTitle("Allow access", for: .normal)
        }
    }
    
    func startSelectingImage() {
        //guard let viewController = self.sender else {
        //    return
        //}
        
        self.imagePicker = ImagePickerModule(self)
        self.imagePicker?.delegate = self
        self.imagePicker?.startImagePicking()
    }
    
    func imagePickerModule(_ module: ImagePickerModule, completeWithImage image: UIImage) {
        //self.dismiss(animated: false)
        self.navigationController?.popViewController(animated: false)
        self.dismissCallback?(image)
    }
    
    func imagePickerModuleRequestRemovePhoto(_ module: ImagePickerModule) {
        
    }
    
    func imagePickerModuleCanceledSeleting(_ module: ImagePickerModule) {
        //self.dismiss(animated: false)
        self.navigationController?.popViewController(animated: false)
        self.dismissCallback?(nil)
    }
}
