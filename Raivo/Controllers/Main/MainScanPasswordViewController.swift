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
import AVFoundation
import OneTimePassword

class MainScanPasswordViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraPreview: UIView!

    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    lazy var captureSession = AVCaptureSession()

    var currentlyCheckingToken: Bool = false

    var lastScannedToken: Token?
    
    private let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                log.error("Failed to get the camera device; no permissions")
                self.captureSession.stopRunning()
                self.cameraUnavailableView(true)
                self.alertToEncourageCameraAccessInitially()
            }
        }

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            log.error("Failed to get the camera device")
            captureSession.stopRunning()
            self.cameraUnavailableView(true)
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            log.error(error.localizedDescription)
            captureSession.stopRunning()
            self.cameraUnavailableView(true)
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(captureSessionDidStart),
            name: .AVCaptureSessionDidStartRunning,
            object: self.captureSession
        )
    }
    
    deinit {
        self.captureSession.stopRunning()
        
        NotificationCenter.default.removeObserver(
            self,
            name: .AVCaptureSessionDidStartRunning,
            object: nil
        )
    }
    
    @objc func captureSessionDidStart() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraPreview.alpha = CGFloat(1)
            })
        }
    }
    
    func cameraUnavailableView(_ unavailable: Bool) {
        DispatchQueue.main.async {
            self.cameraUnavailableLabel.isHidden = !unavailable
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
        
        currentlyCheckingToken = false
        
        cameraPreview.layoutIfNeeded()
        videoPreviewLayer?.frame.size = cameraPreview.frame.size
        
        guard videoPreviewLayer != nil else {
            return
        }
        
        cameraPreview.layer.addSublayer(videoPreviewLayer!)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.global().async {
            self.captureSession.stopRunning()
        }
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 || currentlyCheckingToken {
            return
        }

        currentlyCheckingToken = true

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let contents = metadataObj.stringValue else {
            log.verbose("The scanned QR code is empty.")
            return BannerHelper.shared.error("Invalid QR code", "The QR code data is empty", wrapper: view) {
                self.currentlyCheckingToken = false
            }
        }
        
        let encodedContents = contents.replacingOccurrences(of: " ", with: "%20")
        
        guard ReceiverHelper.shared.isValid(encodedContents) else {
            log.verbose("The scanned QR code is not a valid OTP (it is a receiver instead).")
            return BannerHelper.shared.error("Invalid QR code", "Please scan your receiver in the settings screen", wrapper: view) {
                self.currentlyCheckingToken = false
            }
        }
        
        guard SeedValueValidator.isValid(encodedContents) else {
            log.verbose("The scanned QR code is not a valid OTP.")
            return BannerHelper.shared.error("Invalid QR code", "The QR code is not a valid OTP", wrapper: view) {
                self.currentlyCheckingToken = false
            }
        }
        
        lastScannedToken = Token(url: URL(string: encodedContents)!)
        performSegue(withIdentifier: "MainCreateScannedOneTimePasswordSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "MainCreateManualOneTimePasswordSegue" {
            let newViewController = segue.destination as! MainCreatePasswordViewController
            newViewController.token = lastScannedToken
            newViewController.navigationItem.title = "Verify"
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Missing permissions!",
                message: "Raivo requires camera access to scan OTP QR codes.",
                preferredStyle: UIAlertController.Style.alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
