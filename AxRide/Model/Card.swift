//
//  Card.swift
//  AxRide
//
//  Created by Administrator on 11/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Stripe

class Card {
    var last4 = ""
    var brand: STPCardBrand = .unknown
    
    init() {        
    }
    
    init(withSTPCard card: STPCard) {
        last4 = card.last4
        brand = card.brand
    }
}
