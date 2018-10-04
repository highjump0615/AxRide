//
//  Chat.swift
//  AxRide
//
//  Created by Administrator on 10/5/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation

class Chat : BaseModel {
    
    //
    // table info
    //
    static let TABLE_NAME = "channel"
    
    
    var senderId: String = ""
    var sender: User?
    
    var text: String = ""
    
    override func tableName() -> String {
        return Chat.TABLE_NAME
    }
}
