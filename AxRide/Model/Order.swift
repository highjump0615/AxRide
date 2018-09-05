//
//  Order.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation

class Order {
    
    static let SEATTYPE_FOUR = 0
    static let SEATTYPE_SIX = 1
    static let SEATTYPE_SHARE = 2
    
    //
    // table info
    //
    static let TABLE_NAME_REQUEST = "requests"
    
    
    var customerId = ""
    var driverId = ""
    
    var latitude = 0.0
    var longitude = 0.0
    
    var from: GooglePlace?
    var to: GooglePlace?
    
    var fee = 0.0
    var seatType = SEATTYPE_FOUR
}
