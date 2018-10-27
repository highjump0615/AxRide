//
//  PaymentStripeViewController.swift
//  AxRide
//
//  Created by Administrator on 10/21/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import WebKit

class PaymentStripeViewController: BaseWebViewController {

    var fromSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        self.title = "Connect Stripe Account"
        
        let userCurrent = User.currentUser!
        let strUrl = "\(Config.urlStripeBase)/connectStripe?email=\(userCurrent.email)"
        let url = URL(string: strUrl)!
        mWebView.load(URLRequest(url: url))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func finish() {
        if self.fromSetting {
            // back to prev page
            self.navigationController?.popViewController(animated: true)
        }
        else {
            // go to main
            goToMain()
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        print(url.absoluteString + ": " + String(navigationAction.navigationType.rawValue))
        
        if url.absoluteString.range(of: "axle://success") != nil {
            action = .cancel                  // Stop in WebView
            
            //
            // update stripe account id of current user
            //
            let userCurrent = User.currentUser!
            let query = userCurrent.getDatabaseRef().child(User.FIELD_STRIPE_ACCOUNTID)
            
            query.observeSingleEvent(of: .value) { (snapshot) in
                // data not found
                if !snapshot.exists() {
                    return
                }
                
                userCurrent.stripeAccountId = snapshot.value as? String
            }
            
            self.finish()
            
            return
        }
    }
}
