//
//  MainDriverViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import GoogleMaps
import GeoFire
import Firebase

class MainDriverViewController: BaseHomeViewController {
    
    @IBOutlet weak var mSwitch: UISwitch!
    @IBOutlet weak var mViewInfo: UIView!
    
    @IBOutlet weak var mViewPanel: UIView!
    
    @IBOutlet weak var mLblPrice: UILabel!
    @IBOutlet weak var mButComplete: UIButton!
    
    var mqueryRequest: DatabaseReference?
    var mqueryPickup: DatabaseReference?
    var mUserIds: [String] = []
    
    @IBOutlet weak var mLblAcceptance: UILabel!
    @IBOutlet weak var mLblRating: UILabel!
    @IBOutlet weak var mLblCancellation: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewInfo.makeRound(r: 16)
        mSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        mButComplete.makeRound();
        
        // empty title
        self.navigationItem.title = " "
        
        let userCurrent = User.currentUser!
        
        // broken state
        self.mSwitch.setOn(!userCurrent.broken, animated: false)
        
        // wait for user request
        mqueryRequest = FirebaseManager.ref().child(Order.TABLE_NAME_ACCEPT).child(userCurrent.id)
        mqueryRequest?.observe(.childAdded, with: { (snapshot) in
            if !snapshot.exists() {
                return
            }
            
            //
            // a request has been added
            //
//            if !userCurrent.accepted {
//                // not approved driver
//                self.alertOk(title: "Not approved yet",
//                             message: "Your driver account should be accepted by Admin",
//                             cancelButton: "OK",
//                             cancelHandler: nil)
//                return
//            }
            
            // if in broken state, cannot accept any request
            if userCurrent.broken {
                return
            }
        
            // if in order, cannot accept any request
            if let _ = self.mOrder {
                return
            }
            
            let userId = snapshot.key
            
            // popup request page
            let requestVC = JobRequestViewController(nibName: "JobRequestViewController", bundle: nil)
            requestVC.userId = userId
            requestVC.parentVC = self
            
            let nav = UINavigationController(rootViewController: requestVC)
            self.present(nav, animated: true, completion: nil)
        })
        
        // listener for order complete
        listenOrderComplete()
        
        // fetch current order
        getOrderInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
        
        //
        // check banned
        //
        
        //
        // update parameters
        //
        let userCurrent = User.currentUser!
        
        if userCurrent.rideRequests > 0 {
            // acceptance
            let dAccept = Double(userCurrent.rideAccepts) / Double(max(userCurrent.rideRequests, 1))
            mLblAcceptance.text = (dAccept * 100.0).format(f: ".2") + " %"
            
            // cancellation
            mLblCancellation.text = ((1 - dAccept) * 100.0).format(f: ".2") + " %"
        }
        
        // ratings
        mLblRating.text = userCurrent.userRate().format(f: ".2")
    }
    
    deinit {
        // remove observers
        mqueryRequest?.removeAllObservers()
        mqueryPickup?.removeAllObservers()
    }
    
    func listenOrderComplete() {
        let userCurrent = User.currentUser!
        
        // wait for remove data from picked
        mqueryPickup = FirebaseManager.ref().child(Order.TABLE_NAME_PICKED).child(userCurrent.id)
        mqueryPickup?.observe(.value, with: { (snapshot) in
            // order has completed, update order
            if !snapshot.exists() {
                self.orderComplete()
            }
        })
    }
    
    func setOrder(_ order: Order?) {
        mOrder = order
        
        updateOrder()
    }
    
    override func updateOrder() {
        super.updateOrder()
        
        // in order
        if let order = mOrder {
            mViewInfo.isHidden = true
            mViewPanel.isHidden = false
            
            // price
            mLblPrice.text = "$\(order.fee.format(f: ".2"))"
            
            // fetch driver
            if order.customer == nil {
                User.readFromDatabase(withId: order.customerId) { (user) in
                    order.customer = user
                    
                    self.showLoadingView(show: false)
                }
            }
            else {
                showLoadingView(show: false)
            }
        }
        else {
            mViewInfo.isHidden = false
            mViewPanel.isHidden = true
        }
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        let userCurrent = User.currentUser!
        
        userCurrent.broken = !mSwitch.isOn
        userCurrent.saveToDatabase(withField: User.FIELD_BROKEN, value: userCurrent.broken)
    }
    
    /// arrived destination
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func onButComplete(_ sender: Any) {
        self.alert(title: "Arrived Destination?",
                   message: "You can ask payment to user for this trip",
                   okButton: "Yes",
                   cancelButton: "No",
                   okHandler: { (_) in
                    self.doCompleteRide()
        }, cancelHandler: nil)
    }
    
    /// complete ride
    func doCompleteRide() {
        guard let order = mOrder else {
            return
        }
        
        // set order status
        order.status = Order.STATUS_ARRIVED
        
        let userCurrent = User.currentUser!
        
        // add a mark to "arrived" table
        let dbRef = FirebaseManager.ref().child(Order.TABLE_NAME_ARRIVED)
        dbRef.child(order.customerId).child(userCurrent.id).setValue(true)
    }
    
    @IBAction func onButChat(_ sender: Any) {
        guard let order = mOrder else {
            return
        }
        
        guard let customer = order.customer else {
            return
        }
        
        // go to chat page
        let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
        chatVC.userTo = customer
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func onButCancel(_ sender: Any) {
        self.alert(title: "Are you sure to cancel this ride?",
                   message: "You may cause no income for this ride",
                   okButton: "OK",
                   cancelButton: "Cancel",
                   okHandler: { (_) in
                    self.doCancelRide()
        }, cancelHandler: nil)
    }
    
    /// cancel ride
    func doCancelRide() {
        guard let order = mOrder else {
            return
        }
        
        // clear data in database
        order.clearFromDatabase()
        
        orderComplete()
    }
    
    func orderComplete() {
        // clear order
        let _ = showMyLocation(location: mCoordinate, updateForce: true)
        setOrder(nil)
        
        // clear map
        mViewMap.clear()
        updateMap()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    /// Called when location has updated
    ///
    /// - Parameters:
    ///   - location: <#location description#>
    ///   - updateForce: <#updateForce description#>
    /// - Returns: <#return value description#>
    override func showMyLocation(location: CLLocationCoordinate2D?, updateForce: Bool = false) -> Bool {
        
        let _ = super.showMyLocation(location: location, updateForce: updateForce)
        
        guard let l = location else {
            return false
        }
        
        let cLoc = CLLocation(latitude: l.latitude, longitude: l.longitude)
        
        // update location driver status
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)
        geoFire.setLocation(cLoc, forKey: User.currentUser!.id)
        
        return true
    }

}
