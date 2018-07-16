//
//  TermViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import WebKit

class TermViewController: BaseViewController {

    @IBOutlet weak var mWebView: WKWebView!
    @IBOutlet weak var mButAccept: UIButton!
    @IBOutlet weak var mIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mWebView.navigationDelegate = self
        
        let url = URL(string: Config.urlTermCondition)!
        mWebView.load(URLRequest(url: url))
        mIndicator.startAnimating()
        
        mButAccept.makeRound(r: 12.0)
        
        showNavbar(transparent: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = "Terms & Conditions"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TermViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // hide loading indicator
        mIndicator.isHidden = true
    }
}
