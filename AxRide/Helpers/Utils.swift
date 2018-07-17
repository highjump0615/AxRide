//
//  Utils.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    static func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
