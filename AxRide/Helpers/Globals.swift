//
//  Globals.swift
//  AxRide
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit

class Globals {
    private static let mInstance = Globals()
    
    var mImgNavbarBg: UIImage?
    var mImgNavbarShadow: UIImage?
    var mColorNavbar: UIColor?
    
    static func shared() -> Globals {
        return mInstance
    }
    
}
