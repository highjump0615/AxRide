//
//  PaymentViewController.swift
//  AxRide
//
//  Created by Administrator on 10/20/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: BaseViewController {
    
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mLblDate: UILabel!
    @IBOutlet weak var mLblPriceService: UILabel!
    @IBOutlet weak var mLblPriceTotal: UILabel!
    
    @IBOutlet weak var mButPay: UIButton!
    
    var order: Order?
    var priceTotal = 0.0
    
    private var customerContext: STPCustomerContext!
    private var paymentContext: STPPaymentContext!
    
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
        self.priceTotal = self.order!.fee * Config.feeRate
        mLblPriceTotal.text = "$\(self.priceTotal.format(f: ".2"))"
        
        // date
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        mLblDate.text = dateFormat.string(from: Date())
        
        customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        paymentContext = STPPaymentContext(customerContext: customerContext)
        
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Payment"
    }
    
    @IBAction func onButPay(_ sender: Any) {
        // check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        // TODO: Payment
        paymentContext.paymentAmount = Int(self.priceTotal * 100)
        paymentContext.requestPayment()
        
        showLoadingView()
    }
    
    /// Review driver
    func gotoReviewPage() {
        // go to driver rate page
        let profileVC = DriverProfileViewController(nibName: "DriverProfileViewController", bundle: nil)
        profileVC.user = self.order?.driver
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        // remove itself from stack
        var navigationArray = self.navigationController?.viewControllers
        navigationArray!.remove(at: (navigationArray?.count)! - 2)
        self.navigationController?.viewControllers = navigationArray!
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

extension PaymentViewController : STPPaymentContextDelegate {
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        if let customerKeyError = error as? MainAPIClient.CustomerKeyError {
            switch customerKeyError {
            case .missingBaseURL:
                // Fail silently until base url string is set
                print("[ERROR]: Please assign a value to `MainAPIClient.shared.baseURLString` before continuing. See `AppDelegate.swift`.")
                self.alertOk(title: "Payment", message: "Error while processing payment", cancelButton: "OK", cancelHandler: nil)
            case .invalidResponse:
                // Use customer key specific error message
                print("[ERROR]: Missing or malformed response when attempting to `MainAPIClient.shared.createCustomerKey`. Please check internet connection and backend response formatting.");
                
                self.alertOk(title: "Payment", message: "Error occured while attepting to create customer key", cancelButton: "OK", cancelHandler: nil)
            }
        }
        else {
            // Use generic error message
            print("[ERROR]: Unrecognized error while loading payment context: \(error)");
            
            self.alertOk(title: "Payment", message: "Could not retrieve payment information", cancelButton: "Retry", cancelHandler: { (action) in
                paymentContext.retryLoading()
            })
        }
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        // Reload related components
        
        print("***payment context changed")
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        
        // Create charge using payment result
        let source = paymentResult.source.stripeID
        let userCurrent = User.currentUser!
        
        
        guard
            let strCustomerId = userCurrent.stripeCustomerId,
            let strAccountId = self.order!.driver?.stripeAccountId else {
                alertOk(title: "Cannot pay right now",
                        message: "The parameters are not initialized yet",
                        cancelButton: "OK",
                        cancelHandler: nil)
                
                showLoadingView(show: false)
                
                return
        }
        
        MainAPIClient.shared.requestOrder(source: source,
                                          amount: paymentContext.paymentAmount,
                                          currency: "usd",
                                          customerId: strCustomerId,
                                          senderId: userCurrent.id,
                                          merchantId: strAccountId,
                                          receiverId: self.order!.driverId) { (error) in
                                            
            guard error == nil else {
                // Error while requesting ride
                completion(error)
                return
            }

            completion(nil)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        // hide loading
        self.showLoadingView(show: false)
        
        switch status {
        case .success:
            // Animate active ride
            print("***success***")
            
            //
            // payment success
            //
            self.order?.clearFromDatabase()
            
            // finish order
            if let mainVC = self.navigationController?.viewControllers[0] as? MainUserViewController {
                mainVC.finishOrder()
            }
            
            self.alert(title: "Payment Done",
                       message: "Would you like to submit feedback for your rider?",
                       okButton: "Yes",
                       cancelButton: "No",
                       okHandler: { (_) in
                        self.gotoReviewPage()
            }, cancelHandler: { (_) in
                // back to main page
                self.navigationController?.popToRootViewController(animated: true)
            })
            
        case .error:
            print("***error***")
            print(error?.localizedDescription ?? "")
            
        case .userCancellation:
            // Reset ride request state
            print("***user cancelled***")
        }
    }
    
}
