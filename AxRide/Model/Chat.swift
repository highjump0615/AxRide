//
//  Chat.swift
//  AxRide
//
//  Created by Administrator on 10/5/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

class Chat : BaseModel {
    
    //
    // table info
    //
    static let TABLE_NAME = "channel"
    static let FIELD_SENDER_ID = "senderId"
    static let FIELD_TEXT = "lastMessage"
    static let FIELD_UPDATED_AT = "time"
    
    
    var senderId: String = ""
    var sender: User?
    
    var updatedAt: Int64 = 0
    
    var text: String = ""
    
    override func tableName() -> String {
        return Chat.TABLE_NAME
    }
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init()
        
        let info = snapshot.value! as! [String: Any?]
        
        self.senderId = info[Chat.FIELD_SENDER_ID] as! String
        self.text = info[Chat.FIELD_TEXT] as! String
        self.updatedAt = info[Chat.FIELD_UPDATED_AT] as! Int64
    }
    
    /// Make chat id, combining 2 user ids
    ///
    /// - Parameters:
    ///   - userId1: <#userId1 description#>
    ///   - userId2: <#userId2 description#>
    /// - Returns: <#return value description#>
    static func makeIdWith2User(_ userId1: String, _ userId2: String) -> String {
        // create a channel room unique id from userid1 and userid2 without considering order.
        let user1 = userId1.lowercased()
        let user2 = userId2.lowercased()
        
        let order = user1.compare(user2)
        if order == .orderedAscending {
            return userId1 + "_" + userId2
        }
        else if order == .orderedDescending {
            return userId2 + "_" + userId1
        }
        
        return userId1 + "_" + userId2
    }
    
    /// save entire object to database for specific fields
    ///
    /// - Parameters:
    ///   - withID: <#withID description#>
    ///   - parentID: <#parentID description#>
    override func saveToDatabaseManually(withID: String? = nil, parentID: String? = nil) {
        super.saveToDatabaseManually(withID: withID, parentID: parentID)
        
        // update fields
        self.updatedAt = FirebaseManager.getServerLongTime()
        
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        
        db.child(Chat.FIELD_TEXT).setValue(self.text)
        db.child(Chat.FIELD_SENDER_ID).setValue(self.senderId)
        db.child(Chat.FIELD_UPDATED_AT).setValue(self.updatedAt)
    }
}
