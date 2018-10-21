//
//  PaymentSetupViewController.swift
//  AxRide
//
//  Created by Administrator on 10/21/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class PaymentSetupViewController: BaseViewController {
    
    @IBOutlet weak var mLblCardNo: UILabel!
    @IBOutlet weak var mButEdit: UIButton!
    @IBOutlet weak var mButSave: UIButton!
    @IBOutlet weak var mButConnect: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // init UI
        mButSave.makeRound(r: 12.0)
        mButConnect.makeRound(r: 12.0)
        
        mButEdit.tintColor = Constants.gColorTheme
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = "Payment Information"
    }
    
    @IBAction func onButEdit(_ sender: Any) {
    }
    
    @IBAction func onButSave(_ sender: Any) {
    }
    
    @IBAction func onButConnect(_ sender: Any) {
        // go to stripe page
        let stripeVC = PaymentStripeViewController(nibName: "PaymentStripeViewController", bundle: nil)
        self.navigationController?.pushViewController(stripeVC, animated: true)
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
