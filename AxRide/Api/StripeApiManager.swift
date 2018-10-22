//
//  StripeAPIManager.swift
//  AxRide
//
//  Created by Administrator on 10/22/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class StripeApiManager {
    
    private static let mInstance = StripeApiManager()
    
    /// shared object
    ///
    /// - Returns: <#return value description#>
    static func shared() -> StripeApiManager {
        return mInstance
    }
    
}

class MainAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let shared = MainAPIClient()
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let strUrl = "\(Config.urlApiBase)/ephemeral_keys"
        
        guard
            let userCurrent = User.currentUser,
            let customerId = userCurrent.stripeCustomerId else {
                completion(nil, CustomerKeyError.missingBaseURL)
                return
        }
        
        let parameters: [String: Any] = ["api_version": apiVersion, "customerId": customerId]
        print(parameters)
        
        Alamofire.request(strUrl,
                          method: .post,
                          parameters: parameters)
            .validate()
            .responseJSON { (response) in
                guard let json = response.result.value as? [AnyHashable: Any] else {
                    print("ephermal error:" + response.error.debugDescription)
                    completion(nil, CustomerKeyError.invalidResponse)
                    return
                }
                
                completion(json, nil)
            }
    }
    
}
