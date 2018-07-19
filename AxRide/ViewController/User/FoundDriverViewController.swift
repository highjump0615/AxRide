//
//  FoundDriverViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class FoundDriverViewController: BaseViewController {
    
    @IBOutlet weak var mViewMain: UIView!
    @IBOutlet weak var mViewPhoto: UIView!
    
    @IBOutlet weak var mLblUserName: UILabel!
    @IBOutlet weak var mLblDistance: UILabel!
    
    @IBOutlet weak var mButUser: UIButton!
    @IBOutlet weak var mButProceed: UIButton!
    
    var homeVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewMain.makeRound(r: 8)
        mButProceed.makeRound(r: 12)
        mViewPhoto.makeRound()
        mButUser.makeRound()
        
        self.title = " "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
    }
    
    @IBAction func onButUser(_ sender: Any) {
        // go to driver profile page
        let profileVC = DriverProfileViewController(nibName: "DriverProfileViewController", bundle: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func onButProceed(_ sender: Any) {
        let parentVC = homeVC as? MainUserViewController
        parentVC?.order = Order()
        
        dismiss(animated: true)
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
