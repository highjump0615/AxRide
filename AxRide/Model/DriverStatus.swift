//
//  DriverStatus.swift
//  AxRide
//
//  Created by Administrator on 9/5/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import CoreLocation

class DriverStatus: BaseModel, NSCopying {
    
    //
    // table info
    //
    static let TABLE_NAME = "driverstatus"
    
    var location: CLLocation?    
    
    override func tableName() -> String {
        return DriverStatus.TABLE_NAME
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DriverStatus()
        
        copy.copyData(with: self)
        copy.location = self.location
        
        return copy
    }
}
