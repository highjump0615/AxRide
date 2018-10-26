//
//  TermViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import WebKit
import Stripe

class TermViewController: BaseWebViewController {
    
    static let TERMS_FROM_SIGNUP = 0
    static let TERMS_FROM_SETTING = 1
    static let PRIVACY_POLICY = 2
    
    var type = TermViewController.TERMS_FROM_SIGNUP
    
    var paymentHelper: PaymentMethodHelper?
    
    @IBOutlet weak var mButAccept: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init payment method helper
        paymentHelper = PaymentMethodHelper(self)
        
        let url = type == TermViewController.PRIVACY_POLICY ?
            URL(string: Config.urlPrivacyPolicy)! : URL(string: Config.urlTermCondition)!
        mWebView.load(URLRequest(url: url))        
        
        mButAccept.makeRound(r: 12.0)
        
        // disable for the first time
        mButAccept.makeEnable(enable: false)
        
        if type != TermViewController.TERMS_FROM_SIGNUP {
            // hide accept button
            mButAccept.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = type == TermViewController.PRIVACY_POLICY ? "Privacy Policy" : "Terms & Conditions"
    }
    
    @IBAction func onButAccept(_ sender: Any) {
        if let userCurrent = User.currentUser {
            // user
            if userCurrent.type == UserType.customer {
                // setup payment
                paymentHelper?.showPaymentMethod()
            }
            // driver
            else {
                // go to application page
                var applicationVC = SignupApplicationViewController(nibName: "SignupApplicationViewController", bundle: nil)
                // check iphone screen size
                if UIScreen.main.bounds.width < 375 {
                    applicationVC = SignupApplicationViewController(nibName: "SignupApplicationViewControllerSmall", bundle: nil)
                }
                
                self.navigationController?.pushViewController(applicationVC, animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - WKNavigationDelegate
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        
        // enable button
        mButAccept.makeEnable(enable: true)
    }
}

extension TermViewController : ARPaymentMethodDelegate {
    func getViewController() -> UIViewController {
        return self
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        goToMain()
        
        // error occured
    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        goToMain()
    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        goToMain()
    }
    
}

