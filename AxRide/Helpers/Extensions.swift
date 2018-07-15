//
//  Extensions.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    /// For setting background color of status bar
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIViewController {
    
    func showNavbar(show: Bool = true, animated: Bool = false) {
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
}
