//
//  MainDriverViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class MainDriverViewController: BaseHomeViewController {
    
    @IBOutlet weak var mSwitch: UISwitch!
    @IBOutlet weak var mViewInfo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewInfo.makeRound(r: 16)
        mSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        
        // empty title
        self.navigationItem.title = " "
        
        // broken state
        self.mSwitch.setOn(!User.currentUser!.broken, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        let userCurrent = User.currentUser!
        
        userCurrent.broken = !mSwitch.isOn
        userCurrent.saveToDatabase(withField: User.FIELD_BROKEN, value: userCurrent.broken)
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
