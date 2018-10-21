//
//  PaymentViewController.swift
//  AxRide
//
//  Created by Administrator on 10/20/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class PaymentViewController: BaseViewController {
    
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mLblDate: UILabel!
    @IBOutlet weak var mLblPriceService: UILabel!
    @IBOutlet weak var mLblPriceTotal: UILabel!
    
    @IBOutlet weak var mButPay: UIButton!
    
    var order: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar(transparent: false)

        // init controls
        mButPay.makeRound(r: 12.0)
        
        mLblName.text = "---"
        if let d = self.order?.driver {
            mLblName.text = d.userFullName()
        }
        mLblPriceService.text = "$\(self.order!.fee.format(f: ".2"))"
        let dPriceTotal = self.order!.fee * Config.feeRate
        mLblPriceTotal.text = "$\(dPriceTotal.format(f: ".2"))"
        
        // date
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        mLblDate.text = dateFormat.string(from: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Payment"
    }
    
    @IBAction func onButPay(_ sender: Any) {
        // TODO: Payment
        
        
        //
        // payment success
        //
//        removeRideRequest()
        
        self.alert(title: "Payment Done",
                   message: "Would you like to submit feedback for your rider?",
                   okButton: "Yes",
                   cancelButton: "No",
                   okHandler: { (_) in
                    self.gotoReviewPage()
        }, cancelHandler: { (_) in
            // finish order
            if let mainVC = self.navigationController?.viewControllers[0] as? MainUserViewController {
                mainVC.finishOrder()
            }
            
            // back to main page
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    func removeRideRequest() {
        let dbRef = FirebaseManager.ref()
        let userCurrent = User.currentUser!
        
        dbRef.child(Order.TABLE_NAME_REQUEST).child(userCurrent.id).removeValue()
        dbRef.child(Order.TABLE_NAME_PICKED).child(userCurrent.id).removeValue()
        dbRef.child(Order.TABLE_NAME_PICKED).child(order!.driverId).removeValue()
    }
    
    /// Review driver
    func gotoReviewPage() {
        // go to driver rate page
        let profileVC = DriverProfileViewController(nibName: "DriverProfileViewController", bundle: nil)
        profileVC.user = self.order?.driver
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
