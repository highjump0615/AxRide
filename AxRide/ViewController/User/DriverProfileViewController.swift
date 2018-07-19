//
//  DriverProfileViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class DriverProfileViewController: BaseViewController {
    
    @IBOutlet weak var mImgViewUser: UIImageView!
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mImgViewLocation: UIImageView!
    @IBOutlet weak var mLblLocation: UILabel!
    
    @IBOutlet weak var mLblReviewCount: UIButton!
    @IBOutlet weak var mTextViewReview: KMPlaceholderTextView!
    
    @IBOutlet weak var mButSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mButSave.makeRound(r: 12)
        
        // set as template image to change color
        mImgViewLocation.image = mImgViewLocation.image!.withRenderingMode(.alwaysTemplate)
        
        mTextViewReview.layer.borderWidth = 1
        mTextViewReview.layer.borderColor = Constants.gColorGray.cgColor
        
        showNavbar(transparent: false)
        
        self.title = "Profile"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mImgViewUser.makeRound()
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
