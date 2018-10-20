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
