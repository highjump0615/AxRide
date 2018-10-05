//
//  BaseHomeViewController.swift
//  AxRide
//
//  Created by Administrator on 8/7/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class BaseHomeViewController: BaseMapViewController {
    
    @IBOutlet weak var mButProfile: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mButProfile.makeRound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update user info
        updateUserInfo()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// update current user info
    func updateUserInfo() {
        let user = User.currentUser!
        
        // photo
        if let photoUrl = user.photoUrl {
            mButProfile.sd_setImage(with: URL(string: photoUrl),
                                    for: .normal,
                                    placeholderImage: UIImage(named: "UserDefault"),
                                    options: .progressiveDownload,
                                    completed: nil)
        }
    }

}
