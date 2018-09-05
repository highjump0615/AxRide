//
//  GooglePlace.swift
//  AxRide
//
//  Created by Administrator on 9/4/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlace {
    
    var name = ""
    var city = ""
    var placeId = ""
    var location: CLLocationCoordinate2D?
    
    init() {        
    }
    
    init(place: GMSPlace) {
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
            
            if component.type == "locality"{
                city = component.name
            }
        })
        
        // placeId
        placeId = place.placeID
        
        // location
        location = place.coordinate
    }
    
}
