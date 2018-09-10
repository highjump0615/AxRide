//
//  GooglePlace.swift
//  AxRide
//
//  Created by Administrator on 9/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlace: BaseModel {
    
    var name = ""
    var city = ""
    var placeId = ""
    var location: CLLocationCoordinate2D?
    
    //
    // table info
    //
    static let FIELD_NAME = "name"
    static let FIELD_PLACEID = "placeId"
    static let FIELD_LATITUDE = "latitude"
    static let FIELD_LONGITUDE = "longitude"
    static let FIELD_CITY = "city"
    
    override init() {
        super.init()
    }
    
    init(place: GMSPlace) {
        super.init()
        
        // name
        if let address = place.formattedAddress {
            name = address
        }
        
        // city
        var keys = [String]()
        place.addressComponents?.forEach{keys.append($0.type)}
        var values = [String]()
        place.addressComponents?.forEach({ (component) in
            keys.forEach{ component.type == $0 ? values.append(component.name): nil}
            
            if component.type == "locality" {
                city = component.name
            }
        })
        
        // placeId
        placeId = place.placeID
        
        // location
        location = place.coordinate
    }
    
    /// init from dictionary
    ///
    /// - Parameter data: <#data description#>
    init(data: [String: Any?]) {
        super.init()
        
        self.name = data[GooglePlace.FIELD_NAME] as! String
        self.placeId = data[GooglePlace.FIELD_PLACEID] as! String

        if let latitude = data[GooglePlace.FIELD_LATITUDE] as? Double,
            let longitude = data[GooglePlace.FIELD_LONGITUDE] as? Double {
            self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        self.city = data[GooglePlace.FIELD_CITY] as! String
    }
    
    override func toDictionary() -> [String: Any] {
        var dict = super.toDictionary()
        
        dict[GooglePlace.FIELD_NAME] = self.name
        dict[GooglePlace.FIELD_PLACEID] = self.placeId
        
        if let location = self.location {
            dict[Order.FIELD_LATITUDE] = location.latitude
            dict[Order.FIELD_LONGITUDE] = location.longitude
        }
        
        dict[GooglePlace.FIELD_CITY] = self.city
        
        return dict
    }
}
