//
//  PaymentMethodHelper.swift
//  AxRide
//
//  Created by Administrator on 10/25/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit
import Stripe
import Toast_Swift

protocol ARPaymentMethodDelegate: ARBaseViewHelperDelegate, STPPaymentMethodsViewControllerDelegate {
}

class PaymentMethodHelper: NSObject {
    
    var viewController: UIViewController
    var delegate: ARPaymentMethodDelegate
    
    init(_ delegate: ARPaymentMethodDelegate) {
        viewController = delegate.getViewController()
        self.delegate = delegate
    }
    
    func showPaymentMethod() {
        // Setup customer context
        let customerContext = STPCustomerContext(keyProvider: MainAPIClient.shared)
        
        // Setup payment methods view controller
        let paymentMethodsViewController = STPPaymentMethodsViewController(configuration: STPPaymentConfiguration.shared(), theme: STPTheme.default(), customerContext: customerContext, delegate: self)
        
        // go to payment methods view controller
        viewController.navigationController?.pushViewController(paymentMethodsViewController, animated: true)
    }
}

extension PaymentMethodHelper: STPPaymentMethodsViewControllerDelegate {
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        // error occured
        self.viewController.alertOk(title: "Error loading payment methods",
                                    message: error.localizedDescription,
                                    cancelButton: "OK") { (action) in
                                        
                                        self.delegate.paymentMethodsViewController(paymentMethodsViewController, didFailToLoadWithError: error)
        }
    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        self.delegate.paymentMethodsViewControllerDidFinish(paymentMethodsViewController)
    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        self.delegate.paymentMethodsViewControllerDidCancel(paymentMethodsViewController)
    }    
}
