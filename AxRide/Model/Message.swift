//
//  Message.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

class Message: BaseModel {
    
    //
    // table info
    //
    static let TABLE_NAME = "messages"
    static let FIELD_SENDER_ID = "senderId"
    static let FIELD_TEXT = "text"
    
    var text: String = ""
    
    var senderId: String = ""
    var sender: User?
    
    private var mTableName = Message.TABLE_NAME
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init()
        
        let info = snapshot.value! as! [String: Any?]
        
        self.senderId = info[Message.FIELD_SENDER_ID] as! String
        self.text = info[Message.FIELD_TEXT] as! String
    }
    
    func setTableName(withID: String, parentID: String) {
        mTableName = "\(Chat.TABLE_NAME)/\(parentID)/\(withID)/\(Message.TABLE_NAME)"
    }
    
    override func tableName() -> String {
        return mTableName
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[Message.FIELD_SENDER_ID] = self.senderId
        dict[Message.FIELD_TEXT] = text
        
        return dict
    }
}
