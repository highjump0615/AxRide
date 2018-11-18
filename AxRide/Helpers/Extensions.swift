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
    
    //
    // hide keyboard
    //
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
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
        // the height of view may change, so we use autoresizing
        let border = UIView(frame: CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width))
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.addSubview(border)
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

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension Date {
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year" :
                "\(year)" + " " + "years"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month" :
                "\(month)" + " " + "months"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day" :
                "\(day)" + " " + "days"
        } else {
            return "a moment ago"        
        }
        
    }
}
