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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // title
        self.title = "Connect Stripe Account"
        
        let userCurrent = User.currentUser!
        let strUrl = Config.urlStripeBase + "connectStripe?email=\(userCurrent.email)"
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

}
