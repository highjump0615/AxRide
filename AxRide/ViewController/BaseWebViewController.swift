//
//  BaseWebViewController.swift
//  AxRide
//
//  Created by Administrator on 10/21/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import WebKit

class BaseWebViewController: BaseViewController {
    
    @IBOutlet weak var mWebView: WKWebView!
    @IBOutlet weak var mIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mWebView.navigationDelegate = self
        mIndicator.startAnimating()
        
        showNavbar(transparent: false)
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

extension BaseWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // hide loading indicator
        mIndicator.isHidden = true
    }
}
