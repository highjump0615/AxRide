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

extension UIImage {
    func crop(toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = self.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
    func resized(toWidth width: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resized(toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}


extension UIViewController {
    
    /// show internet connection error
    func showConnectionError() {
        alertOk(title: "No internet connection",
                message: "Please connect to the internet and try again",
                cancelButton: "OK",
                cancelHandler: nil)
    }
    
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
    
    //
    // navigation bar
    //
    func showNavbar(show: Bool = true, transparent: Bool = true, animated: Bool = true) {
        if transparent {
            // Sets background to a blank/empty image
            if Globals.shared().mImgNavbarBg == nil {
                // save the original image to restore in colored navigation bar
                Globals.shared().mImgNavbarBg = self.navigationController?.navigationBar.backgroundImage(for: .default)
            }
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

            // Sets shadow (line below the bar) to a blank image
            if Globals.shared().mImgNavbarShadow == nil {
                // save the original image to restore in colored navigation bar
                Globals.shared().mImgNavbarShadow = self.navigationController?.navigationBar.shadowImage
            }
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
        else {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.barTintColor = Constants.gColorPurple
        }
    
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(!show, animated: animated)
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
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(colorImage, for: state)
    }
    
    func makeEnable(enable: Bool) {
        self.isEnabled = enable
        self.alpha = enable ? 1 : 0.6
    }

}
