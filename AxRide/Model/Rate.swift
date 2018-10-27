//
//  Rate.swift
//  AxRide
//
//  Created by Administrator on 10/20/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class Rate: BaseModel {
    
    //
    // table info
    //
    static let TABLE_NAME = "rates"
    
    static let FIELD_RATING = "rate"
    static let FIELD_TEXT = "rateContent"
    static let FIELD_USERID = "userId"
    
    
    var rating = 0.0
    var text = ""
    
    var userId = ""
    var user: User?
    
    
    override func tableName() -> String {
        return Rate.TABLE_NAME
    }
    
    override init() {
        super.init()
        
        if let userCurrent = User.currentUser {
            self.user = userCurrent
            self.userId = userCurrent.id
        }
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[Rate.FIELD_RATING] = self.rating
        dict[Rate.FIELD_TEXT] = self.text
        dict[Rate.FIELD_USERID] = self.userId
        
        return dict
    }
    
}
