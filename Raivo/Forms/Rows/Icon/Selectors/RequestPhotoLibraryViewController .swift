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

public class RequestPhotoLibraryViewController : UIViewController {
	
	@IBOutlet var lblSubTitle: UILabel!
	@IBOutlet var btnAllow: UIButton!

    var dismissCallback: (() -> Void)?
    
    func set(dismissCallback: @escaping () -> Void) {
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
		//navigationController?.popViewController(animated: true)
		self.dismiss(animated: true)
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
					self.dismissCallback?()
					//self.navigationController?.popViewController(animated: true)
					self.dismiss(animated: true)
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
}
