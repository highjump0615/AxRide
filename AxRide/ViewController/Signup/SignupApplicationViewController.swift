//
//  SignupApplicationViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class SignupApplicationViewController: BaseViewController {
    
    @IBOutlet weak var mViewLicense: UIView!
    @IBOutlet weak var mViewInsurance: UIView!
    @IBOutlet weak var mViewRegistration: UIView!
    
    @IBOutlet weak var mImgViewLicense: UIImageView!
    @IBOutlet weak var mImgViewInsurance: UIImageView!
    @IBOutlet weak var mImgViewRegistration: UIImageView!
    
    @IBOutlet weak var mButLicense: UIButton!
    @IBOutlet weak var mButInsurance: UIButton!
    @IBOutlet weak var mButRegistration: UIButton!
    @IBOutlet weak var mButSubmit: UIButton!
    
    @IBOutlet weak var mButDeclare: UIButton!
    @IBOutlet weak var mImgViewCheck: UIImageView!
    
    var mButSelected: UIButton?
    
    var photoHelper: PhotoViewHelper?
    
    let mColorSelected = UIColor(red: 255/255.0, green: 86/255.0, blue: 23/255.0, alpha: 1.0)
    let mColorUnSelected = UIColor(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showNavbar(transparent: false)
        
        self.title = "Application"
        
        // init photo view helper
        photoHelper = PhotoViewHelper(self)
        
        // corner rounds
        mButLicense.makeRound(r: 12)
        mButInsurance.makeRound(r: 12)
        mButRegistration.makeRound(r: 12)
        mButSubmit.makeRound(r: 12)
        
        // check box
        mImgViewCheck.image = mImgViewCheck.image!.withRenderingMode(.alwaysTemplate)
        mImgViewCheck.tintColor = mColorUnSelected
        mButDeclare.isSelected = false
        
        mButSubmit.makeEnable(enable: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // borders
        mViewLicense.addTopBorderWithColor(color: Constants.gColorGray, width: 0.5)
        mViewInsurance.addTopBorderWithColor(color: Constants.gColorGray, width: 0.5)
        mViewRegistration.addTopBorderWithColor(color: Constants.gColorGray, width: 0.5)
        mViewRegistration.addBottomBorderWithColor(color: Constants.gColorGray, width: 0.5)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onButUploadData(_ sender: Any) {
        mButSelected = sender as? UIButton
        photoHelper?.selectImageFromPicker()
    }
    
    @IBAction func onButSubmit(_ sender: Any) {
        // go to payment method page
        let psVC = PaymentStripeViewController(nibName: "PaymentStripeViewController", bundle: nil)
        self.navigationController?.pushViewController(psVC, animated: true)
    }
    
    @IBAction func onButDeclare(_ sender: Any) {
        mButDeclare.isSelected = !mButDeclare.isSelected
        
        mImgViewCheck.tintColor = mButDeclare.isSelected ? mColorSelected : mColorUnSelected
        mButSubmit.makeEnable(enable: mButDeclare.isSelected)
    }
}

extension SignupApplicationViewController: ARUpdateImageDelegate {
    func onUpdateImage(_ image: UIImage, tag: Int) {
        if mButSelected == mButLicense {
            mImgViewLicense.image = image
        }
        else if mButSelected == mButInsurance {
            mImgViewInsurance.image = image
        }
        else if mButSelected == mButRegistration {
            mImgViewRegistration.image = image
        }
    }
    
    func getViewController() -> UIViewController {
        return self
    }
    
}
