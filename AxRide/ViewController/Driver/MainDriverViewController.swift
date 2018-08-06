//
//  MainDriverViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class MainDriverViewController: BaseMapViewController {
    
    @IBOutlet weak var mSwitch: UISwitch!
    @IBOutlet weak var mViewInfo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewInfo.makeRound(r: 16)
        mSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        
        // empty title
        self.navigationItem.title = " "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
    }
    
    @IBAction func onButProfile(_ sender: Any) {
        // go to profile page
        let profileVC = ProfileDriverViewController(nibName: "ProfileDriverViewController", bundle: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func onButSetting(_ sender: Any) {
        // go to settings page
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsController = storyboard.instantiateViewController(withIdentifier: "settingsController") as! SettingsViewController
        
        self.navigationController?.pushViewController(settingsController, animated: true)
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
