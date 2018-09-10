//
//  BaseModel.swift
//  AxRide
//
//  Created by Administrator on 8/5/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

class BaseModel {
    
    //
    // table info
    //
    static let FIELD_DATE = "createdAt"
    
    var id = ""
    var createdAt: Int64 = FirebaseManager.getServerLongTime()
    
    init() {        
    }
    
    init(snapshot: DataSnapshot) {
        self.id = snapshot.key
        
        let info = snapshot.value! as! [String: Any?]
        if let createdAt = info[BaseModel.FIELD_DATE] {
            self.createdAt = createdAt as! Int64
        }
    }
        
    func tableName() -> String {
        // virtual func
        return "base"
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict[BaseModel.FIELD_DATE] = createdAt
        
        return dict
    }
    
    private func getDatabaseRef(withID: String? = nil, parentID: String? = nil) -> DatabaseReference {
        var strDb = tableName()
        if let parent = parentID {
            strDb += "/" + parent
        }
        
        let database = FirebaseManager.ref().child(strDb)
        
        if let strId = withID, !strId.isEmpty {
            return database.child(strId)
        }
        
        if self.id.isEmpty {
            self.id = database.childByAutoId().key
        }
        
        return database.child(self.id)
    }
    
    /// save entire object to database ref path
    ///
    /// - Parameter path: <#path description#>
    func saveToDatabaseRaw(path: String) {
        let database = FirebaseManager.ref().child(path)
        database.setValue(self.toDictionary())
    }
    
    /// save entire object to database
    ///
    /// - Parameters:
    ///   - withID: <#withID description#>
    ///   - parentID: <#parentID description#>
    func saveToDatabase(withID: String? = nil, parentID: String? = nil) {
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        db.setValue(self.toDictionary())
    }
    
    /// save child value to databse
    ///
    /// - Parameters:
    ///   - withField: <#withField description#>
    ///   - value: <#value description#>
    ///   - withID: <#withID description#>
    ///   - parentID: <#parentID description#>
    func saveToDatabase(withField: String?, value: Any, withID: String? = nil, parentID: String? = nil) {
        let db = getDatabaseRef(withID: withID, parentID: parentID)
        db.child(withField!).setValue(value)
    }
    
    func isEqual(to: BaseModel) -> Bool {
        return id == to.id
    }
    
    func copyData(with: BaseModel) {
        id = with.id
        createdAt = with.createdAt
    }
}
