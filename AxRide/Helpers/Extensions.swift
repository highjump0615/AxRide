//
//  Extensions.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIApplication {
    
    /// For setting background color of status bar
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIViewController {
    
    func alertOk(title: String, message: String, cancelButton: String, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelButton, style: .default, handler: cancelHandler)
        
        alertController.addAction(cancelAction)
        
        alertController.view.tintColor = UIColor.darkGray
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, okButton: String, cancelButton: String, okHandler: ((UIAlertAction) -> ())?, cancelHandler: ((UIAlertAction) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okButton, style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: cancelButton, style: .cancel, handler: cancelHandler)
        
        alertController.view.tintColor = UIColor.darkGray
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    static func takePhoto<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
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
            doTakePhoto(viewController: viewController)
            break
            
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    doTakePhoto(viewController: viewController)
                } else {
                    
                }
            }
        }
        
        
        
    }
    
    static func doTakePhoto<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
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
        picker.delegate = viewController
        picker.allowsEditing = true
        picker.sourceType = .camera
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    static func loadFromGallery<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate{
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            doLoadFromGallery(viewController: viewController)
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
                    doLoadFromGallery(viewController: viewController)
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
    
    static func doLoadFromGallery<T: UIViewController>(viewController: T) where T: UINavigationControllerDelegate, T: UIImagePickerControllerDelegate {
        
        let picker = UIImagePickerController()
        picker.delegate = viewController
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        viewController.present(picker, animated: true, completion: nil)
    }
}

extension UIView {
    
    /// fille round
    func makeRound(r: CGFloat = 0) {
        let radius: CGFloat = r == 0 ? self.frame.size.height / 2.0 : r
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}
