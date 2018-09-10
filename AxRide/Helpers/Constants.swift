//
//  Constants.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit
import Reachability

// colors
class Constants {
    
    static let gColorTheme = UIColor(red: 211/255.0, green: 25/255.0, blue: 213/255.0, alpha: 1.0)
    static let gColorPurple = UIColor(red: 95/255.0, green: 2/255.0, blue: 164/255.0, alpha: 1.0)
    static let gColorSemiPurple = UIColor(red: 117/255.0, green: 28/255.0, blue: 174/255.0, alpha: 1.0)
    static let gColorGray = UIColor(red: 90/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1.0)

    static let reachability = Reachability(hostname: "www.google.com")!
    
    static let MAX_DISTANCE = 10.0 // 10km
}
