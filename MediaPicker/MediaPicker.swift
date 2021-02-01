//
//  MediaPicker.swift
//  Quickerala
//
//  Created by Bibin on 16/08/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import AVFoundation
import Photos
import DKImagePickerController
import CropViewController
import MobileCoreServices

/// Wrapper class for picking media(images, videos, pdfs). Use this class to pick files from device.
final class MediaManager {
    
    /// A common enum that represents permission for both Camera and Photos.
    enum MediaPermission { case notDetermined, restricted, denied, authorized }
    
    /// Media fetch source.
    enum MediaSource: String {
        case camera = "Camera"
        case photos = "Photos"
        var description: String {
            switch self {
            case .camera: return "Camera"
            case .photos: return "Photos or Videos"
            }
        }
    }
    
    private static var cropViewControllerDelegate: CustomCropViewControllerDelegate?
    /// This variable exist just to hold a strong reference to delegate class.
    private static var filePickerDelegate: CustomFilePickerDelegete?

    /// Use this function to pick desired media.
    /// this function manages permission also.
    ///
    /// - Parameters:
    ///   - type: type of media expected to pick.
    ///   - count: maximum number of media that is selected.
    ///   - enableCamera: Should the camera be enabled for getting the media
    ///   - completion: This will be invoked, once user finishes picking the media with the URLs of the media assets.
    static func pick(_ type: MediaType = .image,
//                     maximum count: Int = 1,
                     enableCamera: Bool = true,
                     completion: @escaping ([URL]) -> Void) {
        
        /// Check if all permissions are availed.
        var allPermissionsAuthorized = true
        for source in [MediaSource.photos, .camera] where [.denied, .restricted].contains(source.permission) {
            self.presentPermissionRequiredAlert(for: source)
            allPermissionsAuthorized = false
            break
        }
        
        guard allPermissionsAuthorized else { return }
        
        /// This block will be called once the user finishes picking assets.
        let onFinish: ([DKAsset]) -> Void = { assets in
            guard let asset = assets.first else { return }
            asset.originalAsset?.getURL { url in
                guard url != nil else { return }
                
                guard [.logo, .image].contains(type) else {
                    let vaidationStatus = File(type, at: url!).validate(using: AWSFileValidator.shared)
                    
                    if case .invalid(let reason) = vaidationStatus {
                        executeInMainThread { UIViewController.top?.alert(with: reason) }
                    } else { completion([url!]) }
                    return
                }
                
                guard let data = try? Data(contentsOf: url!),
                let image = UIImage(data: data) else { return }
                
                cropViewControllerDelegate = .init(with: type, completion: completion)
                let cropVC = CropViewController(image: image)
                cropVC.doneButtonTitle = "Upload"
                cropVC.delegate = cropViewControllerDelegate
                UIViewController.top?.present(cropVC, animated: true)
            }
        }

        /// Present asset picker.
        let picker = DKImagePickerController()
        picker.singleSelect = true
        picker.autoCloseOnSingleSelect = false
        picker.maxSelectableCount = 1
        picker.assetType = [.logo, .image].contains(type) ? .allPhotos : .allVideos
        picker.didSelectAssets = onFinish
        picker.modalPresentationStyle = .fullScreen
        executeInMainThread { UIViewController.top?.present(picker, animated: true) }

    }
    
    static func pickFiles(completion: @escaping ([URL]) -> Void) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        filePickerDelegate = .init(with: .catalogue, completion: completion)
        documentPicker.delegate = filePickerDelegate
        documentPicker.modalPresentationStyle = .fullScreen
        executeInMainThread { UIViewController.top?.present(documentPicker, animated: true, completion: nil) }
    }
}

/// This class implements "DKImagePickerControllerBaseUIDelegate", overrides "imagePickerController: didSelectAssets"
/// and perform validation of image/video.
final class CustomCropViewControllerDelegate: NSObject {
    let type: MediaType!
    let completion: ([URL]) -> Void
    init(with type: MediaType, completion: @escaping ([URL]) -> Void) {
        self.type = type
        self.completion = completion
    }
}

extension CustomCropViewControllerDelegate: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // save image to local disk,
        // create file and validate
        //if invalied, show alert with reason
        // if valid completion with URL
        
        let urlString = NSHomeDirectory().appending(image.saveToDocumentDirectory())
        let url = URL(fileURLWithPath: urlString)
        let vaidationStatus = File(self.type, at: url).validate(using: AWSFileValidator.shared)
        
        if case .invalid(let reason) = vaidationStatus {
            executeInMainThread { UIViewController.top?.alert(with: reason) }
        } else {
            cropViewController.dismiss(animated: true) { self.completion([url]) }
        }
    }
}

private extension MediaManager {
    
    /// Use this function to indicate user to enable permission.
    ///
    /// - Parameter mediaSource: Permission required source.
    static func presentPermissionRequiredAlert(for mediaSource: MediaSource) {
        
        let message = Bundle.main.applicationName + " does not have access to your " + mediaSource.description + "."
                      + " To enable access, tap Settings and turn on " + mediaSource.rawValue + "."
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        let settings = UIAlertAction(title: "Settings", style: .default) { _ in URL(string: UIApplication.openSettingsURLString)?.open() }
        alert.addAction(settings)
        alert.preferredAction = settings
        executeInMainThread { UIViewController.top?.present(alert, animated: true) }
    }
}

final class CustomFilePickerDelegete: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    var type: MediaType
    var completion: ([URL]) -> Void = { _ in }
   
    init(with type: MediaType, completion: @escaping ([URL]) -> Void) {
        self.type = type
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else { completion(urls); return }
        let validation = File(self.type, at: urls.first!).validate(using: AWSFileValidator.shared)
        if case .invalid(let reason) = validation {
            executeInMainThread { UIViewController.top?.alert(with: reason) }
            completion([])
        } else { completion(urls) }
    }
}

/// A Protocol to unify Photos & Camera permissions.
private protocol MediaPermissionRepresentable {
    var mediaPermission: MediaManager.MediaPermission { get }
}

/// Maps PHAuthorizationStatus to MediaPermission
extension PHAuthorizationStatus: MediaPermissionRepresentable {
    var mediaPermission: MediaManager.MediaPermission {
        let mappedPermissions = [PHAuthorizationStatus.notDetermined: MediaManager.MediaPermission.notDetermined,
                                 .restricted: .restricted, .denied: .denied, .authorized: .authorized ]
        return mappedPermissions[self]!
    }
}

/// Maps AVAuthorizationStatus to MediaPermission
extension AVAuthorizationStatus: MediaPermissionRepresentable {
    var mediaPermission: MediaManager.MediaPermission {
        let mappedPermissions = [AVAuthorizationStatus.notDetermined: MediaManager.MediaPermission.notDetermined,
                                 .restricted: .restricted, .denied: .denied, .authorized: .authorized ]
        return mappedPermissions[self]!
    }
}

extension MediaManager.MediaSource {
    var permission: MediaManager.MediaPermission {
        switch self {
        case .camera: return AVCaptureDevice.authorizationStatus(for: .video).mediaPermission
        case .photos: return PHPhotoLibrary.authorizationStatus().mediaPermission
        }
    }
}

private extension PHAsset {
    
    /// This function will return a
    ///
    /// - Parameter completion: Returns local URL of the file.
    func getURL(completion: @escaping (URL?) -> Void) {
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ -> Bool in return true }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput, _) in
                completion(contentEditingInput?.fullSizeImageURL)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .current
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) {(asset, _, _) in
                guard let urlAsset = asset as? AVURLAsset else { completion(nil); return }
                completion(urlAsset.url)
            }
        }
    }
}

extension UIImage {
    func saveToDocumentDirectory() -> String {
        let directoryPath = NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath),
                                                        withIntermediateDirectories: true, attributes: nil)
            } catch {
               
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"

        let filename = dateFormatter.string(from: Date()).appending(".jpg")
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try self.jpegData(compressionQuality: 0.3)?.write(to: url, options: .atomic)
            return String.init("/Documents/\(filename)")

        } catch {
            Log.debug("file cant not be save at path \(filepath), with error : \(error)")
            return filepath
        }
    }
}
