//
//  PhotoViewHelper.swift
//  AxRide
//
//  Created by Administrator on 10/26/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit
import Photos


protocol ARUpdateImageDelegate: ARBaseViewHelperDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int)
}

class PhotoViewHelper: NSObject {
    
    var viewController: UIViewController
    var delegate: ARUpdateImageDelegate
    
    init(_ delegate: ARUpdateImageDelegate) {
        viewController = delegate.getViewController()
        self.delegate = delegate
    }
    
    func selectImageFromPicker(_ tag: Int = 0) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            self.takePhoto(tag)
        }))
        
        alert.addAction(UIAlertAction(title: "Select from gallery", style: .default, handler: { (action) in
            self.loadFromGallery(tag)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func takePhoto(_ tag: Int = 0) {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied: fallthrough
        case .restricted:
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)
            break
        case .authorized:
            doTakePhoto(tag)
            break
            
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    self.doTakePhoto(tag)
                } else {
                    
                }
            }
        }
    }
    
    func doTakePhoto(_ tag: Int = 0) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.alert(title: "Camera", message: "You are restricted using the camera. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.view.tag = tag
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func loadFromGallery(_ tag: Int = 0) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            doLoadFromGallery(tag)
            break
            
        case .denied, .restricted :
            //handle denied status
            
            viewController.alert(title: "Camera", message: "You are restricted using photo gallery. Go to settings to enable it.", okButton: "Go to Settings", cancelButton: "Cancel", okHandler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }, cancelHandler: nil)
            
            return
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    self.doLoadFromGallery(tag)
                    // as above
                    break
                case .denied, .restricted:
                    // as above
                    break
                case .notDetermined:
                    // won't happen but still
                    break
                }
            }
        }
    }
    
    func doLoadFromGallery(_ tag: Int = 0) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.view.tag = tag
        
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension PhotoViewHelper : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let nTag = picker.view.tag
            delegate.onUpdateImage(chosenImage, tag: nTag)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
