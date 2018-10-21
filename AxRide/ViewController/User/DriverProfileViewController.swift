//
//  DriverProfileViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import IHKeyboardAvoiding
import Cosmos

class DriverProfileViewController: BaseViewController {
    
    @IBOutlet weak var mImgViewUser: UIImageView!
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mImgViewLocation: UIImageView!
    @IBOutlet weak var mLblLocation: UILabel!
    
    @IBOutlet weak var mLblRate: UILabel!
    @IBOutlet weak var mCosmosRate: CosmosView!
    @IBOutlet weak var mButReviewCount: UIButton!
    @IBOutlet weak var mTextViewReview: KMPlaceholderTextView!
    
    @IBOutlet weak var mCosmosRateNew: CosmosView!
    @IBOutlet weak var mButSave: UIButton!
    
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mButSave.makeRound(r: 12)
        
        // set as template image to change color
        mImgViewLocation.image = mImgViewLocation.image!.withRenderingMode(.alwaysTemplate)
        
        mTextViewReview.layer.borderWidth = 1
        mTextViewReview.layer.borderColor = Constants.gColorGray.cgColor
        
        showNavbar(transparent: false)
        
        // keyboard avoiding
        KeyboardAvoiding.setAvoidingView(self.view, withTriggerView: mTextViewReview)
        
        self.title = "Profile"
        
        self.hideKeyboard()
        
        //
        // init data
        //
        
        if let user = self.user {
            // photo
            if let photoUrl = user.photoUrl {
                mImgViewUser.sd_setImage(with: URL(string: photoUrl),
                                         placeholderImage: UIImage(named: "UserDefault"),
                                         options: .progressiveDownload,
                                         completed: nil)
            }
            
            // name
            mLblName.text = user.userFullName()
            
            // location
            self.mImgViewLocation.isHidden = Utils.isStringNullOrEmpty(text: user.location)
            mLblLocation.text = user.location
            
            // rate
            mCosmosRate.rating = user.userRate()
            let strRating = mCosmosRate.rating.format(f: ".1")
            mLblRate.text = strRating
            
            // review count
            mButReviewCount.setTitle("\(user.rateCount) reviews", for: .normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mImgViewUser.makeRound()
    }

    @IBAction func onButChat(_ sender: Any) {
        // go to chat page
//        let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
//        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func onButSave(_ sender: Any) {
        // check validation
        if mCosmosRateNew.rating <= 0 {
            alertOk(title: "Input rate", message: "Rate value cannot be 0", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        // make new rate
        let rateNew = Rate()
        rateNew.rating = mCosmosRateNew.rating
        rateNew.text = mTextViewReview.text
        
        rateNew.saveToDatabase(parentID: self.user!.id)

        // update user's rate
        if let u = self.user {
            u.rateCount += 1
            u.rate += mCosmosRateNew.rating
            
            u.saveToDatabase(withField: User.FIELD_RATECOUNT, value: u.rateCount)
            u.saveToDatabase(withField: User.FIELD_RATE, value: u.rate)
        }
        
        self.alertOk(title: "Submit Success",
                     message: "Thank you for leaving a review",
                     cancelButton: "OK",
                     cancelHandler: { (action) in                        
                        // back to main page
                        self.navigationController?.popToRootViewController(animated: true)
        })
                     
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
