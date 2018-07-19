//
//  MainUserViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class MainUserViewController: BaseMapViewController {
    
    @IBOutlet weak var mButProfile: UIButton!
    @IBOutlet weak var mViewSearch: UIView!
    @IBOutlet weak var mViewLocation: UIView!
    
    @IBOutlet weak var mViewRide: UIView!
    @IBOutlet weak var mImgViewRideNormal: UIImageView!
    @IBOutlet weak var mImgViewRideSuv: UIImageView!
    @IBOutlet weak var mImgViewRideShare: UIImageView!
    
    @IBOutlet weak var mTextSearch: UITextField!
    @IBOutlet weak var mTextLocationFrom: UITextField!
    @IBOutlet weak var mTextLocationTo: UITextField!
    
    static let RIDE_TYPE_NORMAL = 0
    static let RIDE_TYPE_SUV = 1
    static let RIDE_TYPE_SHARE = 2
    
    var mnRideType = RIDE_TYPE_NORMAL
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mButProfile.makeRound()
        
        mViewSearch.makeRound(r: 10)
        mViewLocation.makeRound(r: 20)
        mViewRide.makeRound(r: 16)
        
        // placeholders
        mTextSearch.attributedPlaceholder = NSAttributedString(string: "Search",
                                                              attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLocationFrom.attributedPlaceholder = NSAttributedString(string: "My Current Location",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLocationTo.attributedPlaceholder = NSAttributedString(string: "Destination",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        
        // images
        mImgViewRideNormal.image = mImgViewRideNormal.image!.withRenderingMode(.alwaysTemplate)
        mImgViewRideSuv.image = mImgViewRideNormal.image!.withRenderingMode(.alwaysTemplate)
        mImgViewRideShare.image = mImgViewRideNormal.image!.withRenderingMode(.alwaysTemplate)
        
        updateRideView()
        
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
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func onButSetting(_ sender: Any) {
        // go to settings page
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsController = storyboard.instantiateViewController(withIdentifier: "settingsController") as! SettingsViewController
        
        self.navigationController?.pushViewController(settingsController, animated: true)
    }
    
    @IBAction func onButRideNormal(_ sender: Any) {
        mnRideType = MainUserViewController.RIDE_TYPE_NORMAL
        updateRideView()
    }
    
    @IBAction func onButRideSuv(_ sender: Any) {
        mnRideType = MainUserViewController.RIDE_TYPE_SUV
        updateRideView()
    }
    
    @IBAction func onButRideShare(_ sender: Any) {
        mnRideType = MainUserViewController.RIDE_TYPE_SHARE
        updateRideView()
    }
    
    func updateRideView() {
        mImgViewRideNormal.tintColor = Constants.gColorGray
        mImgViewRideSuv.tintColor = Constants.gColorGray
        mImgViewRideShare.tintColor = Constants.gColorGray
        
        switch mnRideType {
        case MainUserViewController.RIDE_TYPE_NORMAL:
            mImgViewRideNormal.tintColor = Constants.gColorPurple
            
        case MainUserViewController.RIDE_TYPE_SUV:
            mImgViewRideSuv.tintColor = Constants.gColorPurple
            
        case MainUserViewController.RIDE_TYPE_SHARE:
            mImgViewRideShare.tintColor = Constants.gColorPurple
            
        default: break
        }
    }
    
    /// clear location from text field
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func onButCloseFrom(_ sender: Any) {
        mTextLocationFrom.text = ""
    }
    
    /// clear location to text field
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func onButCloseTo(_ sender: Any) {
        mTextLocationTo.text = ""
    }
    
    /// exchange from & to address
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func onButLocationExchange(_ sender: Any) {
        let strAddrFrom = mTextLocationFrom.text
        mTextLocationFrom.text = mTextLocationTo.text
        mTextLocationTo.text = strAddrFrom
    }
    
    @IBAction func onButGo(_ sender: Any) {
        // go to profile page
        let foundVC = FoundDriverViewController(nibName: "FoundDriverViewController", bundle: nil)
        
        let nav = UINavigationController()
        nav.setViewControllers([foundVC], animated: true)
        
        present(nav, animated: true, completion: nil)
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

extension MainUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

