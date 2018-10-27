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
    
    func createCustomerId(email: String,
                          completion: @escaping (_ error: Error?, _ value: String?)->() = {_,_ in }) {
        let strUrl = "\(Config.urlApiBase)/createCustomStripe"
        let parameters: [String: Any] = ["email": email]
        
        Alamofire.request(strUrl,
                          method: .post,
                          parameters: parameters)
            .validate()
            .responseJSON { (response) in
                guard let json = response.result.value as? [AnyHashable: Any] else {
                    print("stripe Customer Id error:" + response.error.debugDescription)
                    completion(response.error, nil)
                    return
                }
                
                completion(nil, json["id"] as? String)
        }
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
    
    enum RequestOrderError: Error {
        case missingBaseURL
        case invalidResponse
    }

    func requestOrder(source: String,
                      amount: Int,
                      currency: String,
                      customerId: String,
                      senderId: String,
                      merchantId: String,
                      receiverId: String,
                      completion: @escaping (RequestOrderError?) -> Void) {
        
        let strUrl = "\(Config.urlApiBase)/order"
        
        // Important: For this demo, we're trusting the `amount` and `currency` coming from the client request.
        // A real application should absolutely have the `amount` and `currency` securely computed on the backend
        // to make sure the user can't change the payment amount from their web browser or client-side environment.
        let parameters: [String: Any] = [
            "source": source,
            "amount": amount,
            "currency": currency,
            "customer_id": customerId,
            "merchant_id": merchantId,
            "sender_id": senderId,
            "receiver_id": receiverId,
            ]
        
        Alamofire.request(strUrl,
                          method: .post,
                          parameters: parameters)
            .validate()
            .responseJSON { (response) in
                guard (response.result.value as? [String: Any]) != nil else {
                    completion(.invalidResponse)
                    return
                }
                
                completion(nil)
            }
    }
}
