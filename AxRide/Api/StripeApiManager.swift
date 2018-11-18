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
    
    func getBasicAuth() -> String{
        return "Bearer \(Config.stripeSecretKey)"
    }
    
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
    
    /// get user card list
    ///
    /// - Parameters:
    ///   - customerId: <#customerId description#>
    ///   - completion: <#completion description#>
    func getCardsList(customerId: String?, completion: @escaping (_ result: [AnyObject]?) -> Void) {
        
        guard let cId = customerId else {
            return
        }

        let strUrl = "https://api.stripe.com/v1/customers/\(cId)/sources"
        var request = URLRequest(url: URL(string: strUrl)!)
        
        //basic auth
        request.setValue(getBasicAuth(), forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        Alamofire.request(request)
            .validate()
            .responseJSON { (response) in
                guard let json = response.result.value as? [AnyHashable: Any] else {
                    print("stripe get card error:" + response.error.debugDescription)
                    completion(nil)
                    return
                }
                
                let cardsArray = json["data"] as? [AnyObject]
                completion(cardsArray)
        }
    }
    
    //create card for given user
    func createCard(customerId: String?, token: STPToken, completion: ((_ success: Bool) -> Void)? = nil) {
        
        guard let cId = customerId else {
            return
        }
        
        let strUrl = "https://api.stripe.com/v1/customers/\(cId)/sources"
        var request = URLRequest(url: URL(string: strUrl)!)
        
        // basic auth
        request.setValue(getBasicAuth(), forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        // token needed
        var params = [String:String]()
        params["source"] = token.tokenId
        
        var str = ""
        params.forEach({ (key, value) in
            str = "\(str)\(key)=\(value)&"
        })
        
        request.httpBody = str.data(using: String.Encoding.utf8)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { (response) in
                guard (response.result.value as? [AnyHashable: Any]) != nil else {
                    print("stripe create card error:" + response.error.debugDescription)
                    completion?(false)
                    return
                }

                completion?(true)
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
