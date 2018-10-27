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
    var to: GooglePlace?
    
    var fee = 0.0
    var rideMode = Order.RIDE_MODE_NORMAL
    
    var status = Order.STATUS_REQUEST
    
    
    override func tableName() -> String {
        if status == Order.STATUS_REQUEST {
            return Order.TABLE_NAME_REQUEST
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
        self.latitude = info[Order.FIELD_LATITUDE] as! Double
        self.longitude = info[Order.FIELD_LONGITUDE] as! Double
        
        self.from = GooglePlace(data: info[Order.FIELD_FROM] as! [String : Any?])
        self.to = GooglePlace(data: info[Order.FIELD_TO] as! [String : Any?])
        
        self.fee = info[Order.FIELD_FEE] as! Double
        self.rideMode = info[Order.FIELD_RIDEMODE] as! Int
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[Order.FIELD_CUSTOMERID] = self.customerId
        dict[Order.FIELD_DRIVERID] = self.driverId
        dict[Order.FIELD_LATITUDE] = self.latitude
        dict[Order.FIELD_LONGITUDE] = self.longitude
        
        if let placeFrom = self.from {
            dict[Order.FIELD_FROM] = placeFrom.toDictionary()
        }
        if let placeTo = self.to {
            dict[Order.FIELD_TO] = placeTo.toDictionary()
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
}
