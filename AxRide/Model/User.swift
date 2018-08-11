//
//  User.swift
//  AxRide
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Firebase

enum UserType : String {
    case driver = "driver"
    case customer = "customer"
    case admin = "admin"
    case notdetermined = "notdetermined"
}


class User : BaseModel {
    
    //
    // table info
    //
    static let TABLE_NAME = "users"
    static let FIELD_EMAIL = "userEmail"
    static let FIELD_FIRSTNAME = "firstName"
    static let FIELD_LASTNAME = "lastName"
    static let FIELD_PHOTO = "photoUrl"
    static let FIELD_LOCATION = "location"
    static let FIELD_TYPE = "userType"
    static let FIELD_BANNED = "banned"
    static let FIELD_TOKEN = "token"
    
    static var currentUser: User?
    
    var email = ""
    
    var firstName = ""
    var lastName = ""
    var photoUrl: String?
    var location:String?
    
    var type = UserType.notdetermined
    var banned: Bool = false
    
    var token: String?
    
    //
    // excludes
    //
    var password = ""
    
    static func readFromDatabase(withId: String, completion: @escaping((User?)->())) {
        let userRef = FirebaseManager.ref().child(TABLE_NAME).child(withId)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // user not found
            if !snapshot.exists() {
                completion(nil)
                return
            }
            
            let user = User(snapshot: snapshot)
            
            completion(user)
        })
    }
    
    override func tableName() -> String {
        return User.TABLE_NAME
    }
    
    init(withId: String) {
        super.init()
        
        self.id = withId
    }
    
    override init(snapshot: DataSnapshot) {
        super.init(snapshot: snapshot)
        
        let info = snapshot.value! as! [String: Any?]
        
        self.id = snapshot.key
        
        self.email = info[User.FIELD_EMAIL] as! String
        
        // first name
        if let firstName = info[User.FIELD_FIRSTNAME] {
            self.firstName = firstName as! String
        }
        
        // last name
        if let lastName = info[User.FIELD_LASTNAME] {
            self.lastName = lastName as! String
        }
        
        self.photoUrl = info[User.FIELD_PHOTO] as? String
        self.location = info[User.FIELD_LOCATION] as? String
        self.token = info[User.FIELD_TOKEN] as? String
        
        // banned
        if let b = info[User.FIELD_BANNED] {
            self.banned = b as! Bool
        }
        
        // type
        if let t = info[User.FIELD_TYPE] {
            self.type = UserType(rawValue: t as! String)!
        }
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[User.FIELD_EMAIL] = self.email
        dict[User.FIELD_FIRSTNAME] = self.firstName
        dict[User.FIELD_LASTNAME] = self.lastName
        dict[User.FIELD_PHOTO] = self.photoUrl
        dict[User.FIELD_LOCATION] = self.location
        dict[User.FIELD_BANNED] = self.banned
        dict[User.FIELD_TOKEN] = self.token
        dict[User.FIELD_TYPE] = self.type.rawValue
        
        return dict
    }
    
    func userFullName() -> String {
        return "\(firstName) \(lastName)"
    }
}
