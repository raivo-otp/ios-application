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

import Photos

class PhotoLibraryManager {

    class var authorized: Bool {
        PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    class func requestAuthorization(completion: @escaping (Bool) -> ()) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                completion(status == .authorized)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        }
    }
    
    class func albumAssetCollection(withTitle title: String) -> PHAssetCollection? {
        let predicate = NSPredicate(format: "localizedTitle = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        if result.count > 0 {
            return result.firstObject
        }
        return nil
    }
}

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            
            self.requestContentEditingInput(with: options) { contentEditingInput, info in
                completionHandler(contentEditingInput?.fullSizeImageURL)
            }
        } else if self.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { asset, audioMix, info in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            }
        }
    }

    class func requestAuthorizationForAddOnly(completion: @escaping (Bool) -> ()) {
        if #available(iOS 14, *) {
            // TODO: - Check if needed. Maybe the default if good enough
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                completion(status == .authorized)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status == .authorized)
            }
        }
    }

    class func albumAssetCollection(withTitle title: String) -> PHAssetCollection? {
        let predicate = NSPredicate(format: "localizedTitle = %@", title)
        let options = PHFetchOptions()
        options.predicate = predicate
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        if result.count > 0 {
            return result.firstObject
        }

        return nil
    }
}
