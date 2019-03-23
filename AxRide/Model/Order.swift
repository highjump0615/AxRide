//
//  Order.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

class Order: BaseModel {
    
    static let STATUS_REQUEST = 0
    static let STATUS_ACCEPTED = 1
    static let STATUS_ARRIVED = 2
    static let STATUS_PAID = 3
    
    static let RIDE_MODE_NORMAL = 0
    static let RIDE_MODE_SUV = 1
    static let RIDE_MODE_SHARE = 2
    
    //
    // table info
    //
    static let TABLE_NAME_REQUEST = "requests"
    static let TABLE_NAME_PICKED = "picked"
    static let TABLE_NAME_ACCEPT = "accepts"
    static let TABLE_NAME_ARRIVED = "arrived"
    static let TABLE_NAME_DONE = "bookhistories"
    
    static let FIELD_CUSTOMERID = "customerId"
    static let FIELD_DRIVERID = "driverId"
    static let FIELD_LATITUDE = "latitude"
    static let FIELD_LONGITUDE = "longitude"
    static let FIELD_FROM = "pickup"
    static let FIELD_TO = "delivery"
    static let FIELD_FEE = "fee"
    static let FIELD_RIDEMODE = "seatType"
    
    
    var customerId = ""
    
    private var mDriverId = ""
    var driverId: String {
        get {
            return mDriverId
        }
        set {
            mDriverId = newValue

            // determine status
            status = mDriverId.isEmpty ? Order.STATUS_REQUEST : Order.STATUS_ACCEPTED
        }
    }
    
    var customer: User?
    var driver: User?
    
    var latitude = 0.0
    var longitude = 0.0
    
    var from: GooglePlace?
    var fromAddr: String?
    var to: GooglePlace?
    var toAddr: String?
    
    var fee = 0.0
    var rideMode = Order.RIDE_MODE_NORMAL
    
    var status = Order.STATUS_REQUEST
    
    
    override func tableName() -> String {
        if status == Order.STATUS_REQUEST {
            return Order.TABLE_NAME_REQUEST
        }
        else if status == Order.STATUS_ARRIVED {
            return Order.TABLE_NAME_DONE
        }
        
        return Order.TABLE_NAME_PICKED
    }
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init(snapshot: snapshot)
        
        let info = snapshot.value! as! [String: Any?]
        
        self.customerId = info[Order.FIELD_CUSTOMERID] as! String
        self.driverId = info[Order.FIELD_DRIVERID] as! String

        // lat, lng are not existing in "done" table
        if let latitude = info[Order.FIELD_LATITUDE] as? Double {
            self.latitude = latitude
        }
        if let longitude = info[Order.FIELD_LONGITUDE] as? Double {
            self.longitude = longitude
        }

        // from will be google place or string
        if let fromData = info[Order.FIELD_FROM] as? [String : Any?] {
            self.from = GooglePlace(data: fromData)
        }
        else if let fromStr = info[Order.FIELD_FROM] as? String {
            self.fromAddr = fromStr
        }
        // to will be google place or string
        if let toData = info[Order.FIELD_TO] as? [String : Any?] {
            self.to = GooglePlace(data: toData)
        }
        else if let toStr = info[Order.FIELD_TO] as? String {
            self.toAddr = toStr
        }
        
        if let fee = info[Order.FIELD_FEE] as? Double {
            self.fee = fee
        }
        
        // ridemode are not existing in "done" table
        if let rideMode = info[Order.FIELD_RIDEMODE] as? Int {
            self.rideMode = rideMode
        }
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[Order.FIELD_CUSTOMERID] = self.customerId
        dict[Order.FIELD_DRIVERID] = self.driverId
        
        if self.latitude > 0 {
            dict[Order.FIELD_LATITUDE] = self.latitude
        }
        if self.longitude > 0 {
            dict[Order.FIELD_LONGITUDE] = self.longitude
        }
        
        if let placeFrom = self.from {
            dict[Order.FIELD_FROM] = placeFrom.toDictionary()
        }
        if let addrFrom = self.fromAddr {
            dict[Order.FIELD_FROM] = addrFrom
        }
        if let placeTo = self.to {
            dict[Order.FIELD_TO] = placeTo.toDictionary()
        }
        if let addrTo = self.toAddr {
            dict[Order.FIELD_TO] = addrTo
        }
        
        dict[Order.FIELD_FEE] = self.fee
        dict[Order.FIELD_RIDEMODE] = self.rideMode
        
        return dict
    }
    
    /// is empty order or not
    ///
    /// - Returns: <#return value description#>
    func isEmpty() -> Bool {
        return customerId.isEmpty || fee <= 0 || from == nil || to == nil
    }
    
    func clear() {
        driverId = ""
        fee = 0
    }
    
    /// remove value
    func removeFromDatabase() {
        //
        // will remove data from difference table based on status
        //
        getDatabaseRef(withID: customerId).removeValue()
        getDatabaseRef(withID: driverId).removeValue()
    }
    
    func removeArriveMark() {
        let database = FirebaseManager.ref().child(Order.TABLE_NAME_ARRIVED)
        database.child(customerId).removeValue()
    }
    
    func clearFromDatabase() {
        removeArriveMark()
        removeFromDatabase()
    }
    
    func updateStatus(_ status: Int) {
        // update order status
        self.status = Order.STATUS_PAID
        
        if status == Order.STATUS_PAID {
            self.fromAddr = self.from?.name
            self.toAddr = self.to?.name
            
            // remove google place objects
            self.from = nil
            self.to = nil
            
            // remove latitude & longitude
            self.latitude = 0
            self.longitude = 0
            
            // save order in "bookhistories" table
            self.saveToDatabase(parentID: self.customerId)
            self.saveToDatabase(parentID: self.driverId)
        }
    }
}
