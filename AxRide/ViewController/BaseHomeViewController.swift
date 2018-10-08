//
//  BaseHomeViewController.swift
//  AxRide
//
//  Created by Administrator on 8/7/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import GoogleMaps

class BaseHomeViewController: BaseMapViewController {
    
    @IBOutlet weak var mButProfile: UIButton!
    
    var mOrder: Order?
    var polygonRoad: GMSPolyline?
    
    var mMarkerFrom: GMSMarker?
    var mMarkerTo: GMSMarker?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mButProfile.makeRound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update user info
        updateUserInfo()
    }
    
    /// fetch current order info
    func getOrderInfo(completion: @escaping (()->()) = {}) {
        let userCurrent = User.currentUser!
        let dbRef = FirebaseManager.ref()
        
        showLoadingView()
        
        let query = dbRef.child(Order.TABLE_NAME_PICKED).child(userCurrent.id)
        query.observeSingleEvent(of: .value) { (snapshot) in
            // order not found
            if !snapshot.exists() {
                self.showLoadingView(show: false)
                return
            }
            
            self.mOrder = Order(snapshot: snapshot)
            
            self.updateMap()
            self.updateOrder()
            
            completion()
        }
    }
    
    /// update map - from, to
    func updateMap() {
        updateMapCamera()
        
        updateFromMark()
        updateToMark()
    }
    
    /// update map camera based on from & to locations
    ///
    /// - Parameter location: <#location description#>
    func updateMapCamera() {
        
        guard let order = mOrder else {
            return
        }
        
        if let coordFrom = order.from?.location, let coordTo = order.to?.location {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(coordFrom)
            bounds = bounds.includingCoordinate(coordTo)
            
            if order.status > Order.STATUS_REQUEST {
                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(140 + 10, 20, 170 + 40, 20))
                mViewMap.animate(with: update)
                
                // draw a road path on the map
                if self.polygonRoad != nil {
                    return
                }
                
                print("about to get routes: \(coordFrom), \(coordTo)")
                
                ApiManager.shared().googleMapGetRoutes(pointFrom: coordFrom, pointTo: coordTo) { (routes, err) in
                    
                    print("fetched routes: \(routes.count), \(err)")
                    
                    for route in routes
                    {
                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                        let points = routeOverviewPolyline?["points"]?.stringValue
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeColor = UIColor.blue
                        polyline.strokeWidth = 3
                        polyline.map = self.mViewMap
                        
                        self.polygonRoad = polyline
                    }
                }
            }
            
            return
        }
        
        moveCameraToLocation(order.from?.location)
        moveCameraToLocation(order.to?.location)
    }
    
    /// update "from marker" on the map
    ///
    /// - Parameter location: <#location description#>
    func updateFromMark() {
        mMarkerFrom?.map = nil
        
        if let l = mOrder!.from?.location {
            mMarkerFrom = GMSMarker()
            mMarkerFrom?.icon = UIImage(named: "MainLocationFrom")
            mMarkerFrom?.position = l
            mMarkerFrom?.map = mViewMap
        }
    }
    
    /// update "to marker" on the map
    ///
    /// - Parameter location: <#location description#>
    func updateToMark() {
        mMarkerTo?.map = nil
        
        if let l = mOrder!.to?.location {
            mMarkerTo = GMSMarker()
            mMarkerTo?.icon = UIImage(named: "MainLocationTo")
            mMarkerTo?.position = l
            mMarkerTo?.map = mViewMap
        }
    }
    
    /// update page based on order status
    func updateOrder() {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// update current user info
    func updateUserInfo() {
        let user = User.currentUser!
        
        // photo
        if let photoUrl = user.photoUrl {
            mButProfile.sd_setImage(with: URL(string: photoUrl),
                                    for: .normal,
                                    placeholderImage: UIImage(named: "UserDefault"),
                                    options: .progressiveDownload,
                                    completed: nil)
        }
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

    //
    // GMSMapViewDelegate
    //
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if self.isMapInited {
            return
        }
        
        updateMap()
        
        self.isMapInited = true
    }
}
