//
//  BaseViewController.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.title = " "
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// show loading mast view
    ///
    /// - Parameter show: show/hide
    func showLoadingView(show: Bool = true) {
        if SVProgressHUD.isVisible() && show {
            // loading view is already shown
            return
        }
        
        SVProgressHUD.dismiss()
        
        if show {
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.show()
        }
    }

    /// go to main page according to user type
    func goToMain() {
        let userCurrent = User.currentUser!
        
        if userCurrent.type == UserType.customer {
            let mainUserVC = MainUserViewController(nibName: "MainUserViewController", bundle: nil)
            self.navigationController?.setViewControllers([mainUserVC], animated: true)
        }
        else {
            let mainDriverVC = MainDriverViewController(nibName: "MainDriverViewController", bundle: nil)
            self.navigationController?.setViewControllers([mainDriverVC], animated: true)
        }
    }
}
