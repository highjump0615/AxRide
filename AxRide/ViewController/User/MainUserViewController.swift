//
//  MainUserViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import GeoFire
import Firebase

class MainUserViewController: BaseHomeViewController {
    
    @IBOutlet weak var mViewSearch: UIView!
    @IBOutlet weak var mViewLocation: UIView!
    @IBOutlet weak var mViewRequest: UIView!
    
    @IBOutlet weak var mViewRide: UIView!
    @IBOutlet weak var mImgViewRideNormal: UIImageView!
    @IBOutlet weak var mImgViewRideSuv: UIImageView!
    @IBOutlet weak var mImgViewRideShare: UIImageView!
    
    @IBOutlet weak var mTextSearch: UITextField!
    @IBOutlet weak var mTextLocationFrom: UITextField!
    @IBOutlet weak var mTextLocationTo: UITextField!
    
    @IBOutlet weak var mViewDriver: UIView!
    @IBOutlet weak var mButCancel: UIButton!
    @IBOutlet weak var mButDriver: UIButton!
    
    @IBOutlet weak var mButGo: UIButton!
    
    @IBOutlet weak var mLblPrice: UILabel!
    
    static let RIDE_TYPE_NORMAL = 0
    static let RIDE_TYPE_SUV = 1
    static let RIDE_TYPE_SHARE = 2
    
    var mnRideType = RIDE_TYPE_NORMAL
    
    var placePickerFrom: GMSPlacePickerViewController?
    var placePickerTo: GMSPlacePickerViewController?
    
    var mMarkerFrom: GMSMarker?
    var mMarkerTo: GMSMarker?
    
    var mViewWaiting: UserWaitPopup?
    
    var mOrder: Order = Order()
    
    var drivers: [DriverStatus] = []
    var selectedDriver: DriverStatus?
    
    var mqueryAccept: DatabaseReference?
    
    var price: Double {
        get {
            return mOrder.fee
        }
        set {
            mOrder.fee = newValue
            mLblPrice.text = (newValue > 0) ? "\(newValue.format(f: ".1"))$" : ""
   
            mButGo.makeEnable(enable: newValue > 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mViewSearch.makeRound(r: 10)
        mViewLocation.makeRound(r: 20)
        mViewRide.makeRound(r: 16)
        mViewDriver.makeRound(r: 6)
        mButCancel.makeRound(r: 6)
        mButDriver.makeRound()
        
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
        
        // clear buttons
        mTextLocationFrom.clearButtonMode = .whileEditing
        mTextLocationTo.clearButtonMode = .whileEditing
        
        // place pickers
        let config = GMSPlacePickerConfig(viewport: nil)
        placePickerFrom = GMSPlacePickerViewController(config: config)
        placePickerFrom?.delegate = self
        placePickerTo = GMSPlacePickerViewController(config: config)
        placePickerTo?.delegate = self
        
        // price
        price = 0
        
        // init waiting popup
        mViewWaiting = UserWaitPopup.getView() as? UserWaitPopup
        mViewWaiting?.delegate = self
        self.view.addSubview(mViewWaiting!)
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // clear map init mark
        self.isMapInited = false
    }
    
    /// update map - from, to
    func updateMap() {
        updateMapCamera()
        
        updateFromMark()
        updateToMark()
    }
    
    /// fetch current order info
    func getOrderInfo() {
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
            
            // fetch current driver
            self.getDriverStatus()
        
            self.updateMap()
            self.updateOrder()
        }
    }
    
    /// fetch current driver status
    func getDriverStatus() {
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)
        
        geoFire.getLocationForKey(mOrder.driverId) { (location, error) in
            self.showLoadingView(show: false)
            
            if let l = location {
                let driver = DriverStatus()
                driver.id = self.mOrder.driverId
                driver.location = l
                
                self.selectedDriver = driver
            }
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
        // exchange address
        let strAddrFrom = mTextLocationFrom.text
        mTextLocationFrom.text = mTextLocationTo.text
        mTextLocationTo.text = strAddrFrom

        // exchange position
        let locationTemp = mOrder.from
        mOrder.from = mOrder.to
        mOrder.to = locationTemp

        // update map
        updateMapCamera()
        
        updateFromMark()
        updateToMark()

    }
    
    /// A driver has accepted the request
    private lazy var mListenerDriver: (DataSnapshot) -> Void = { snapshot in
        if !snapshot.exists() {
            return
        }
        
        let driverId = snapshot.value as! String
        if driverId.isEmpty {
            return
        }
        
        for driver in self.drivers {
            if driver.id == driverId {
                self.selectedDriver = driver.copy() as? DriverStatus
                break
            }
        }

        // close wait dialog
        self.mViewWaiting?.onButCancel(nil)
    }
    
    @IBAction func onButGo(_ sender: Any) {
        let userCurrent = User.currentUser!
        
        // add request to "request" table
        self.mOrder.customerId = userCurrent.id
        if let coord = self.mCoordinate {
            self.mOrder.latitude = coord.latitude
            self.mOrder.longitude = coord.longitude
        }
        self.mOrder.saveToDatabase(withID: userCurrent.id)
        
        //
        // show loading
        //
        mViewWaiting?.frame = self.view.bounds
        mViewWaiting?.showView(bShow: true, animated: true)
        mViewWaiting?.startTimer()
        
        // clear driver list
        drivers.removeAll()
        
        //
        // load drivers near around
        //
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)

        // get current location
        var dLatitude = self.mOrder.from?.location?.latitude
        var dLongitude = self.mOrder.to?.location?.latitude
        if let coord = self.mCoordinate {
            dLatitude = coord.latitude
            dLongitude = coord.longitude
        }
        
        let queryDriver = geoFire.query(at: CLLocation(latitude: dLatitude!,
                                                       longitude: dLongitude!),
                                        withRadius: Constants.MAX_DISTANCE)
        
        queryDriver.observe(.keyEntered) { (key, location) in
            print("Entered:\(key) latitude:\(location.coordinate.latitude) longitude:\(location.coordinate.longitude)" )
            
            // add new driver to list
            let newDriver = DriverStatus()
            newDriver.id = key
            newDriver.location = location
            
            self.drivers.append(newDriver)
            
            // add a mark to "accepts" table
            let acceptRef = FirebaseManager.ref().child(Order.TABLE_NAME_ACCEPT)
            acceptRef.child(key).child(userCurrent.id).setValue("request")
        }
        
        queryDriver.observeReady {
            print("ready")
        }
        
        // wait for drivers accept
        mqueryAccept = FirebaseManager.ref().child(Order.TABLE_NAME_REQUEST).child(userCurrent.id).child(Order.FIELD_DRIVERID)
        mqueryAccept?.observe(.value, with: mListenerDriver)
        
//        // go to profile page
//        let foundVC = FoundDriverViewController(nibName: "FoundDriverViewController", bundle: nil)
//        foundVC.homeVC = self
//
//        let nav = UINavigationController()
//        nav.setViewControllers([foundVC], animated: true)
//
//        present(nav, animated: true, completion: nil)
    }
    
    /// update page based on order status
    func updateOrder() {
        
        // show/hide location & ride
        mViewLocation.isHidden = !(mOrder.status == Order.STATUS_REQUEST)
        mViewRide.isHidden = !(mOrder.status == Order.STATUS_REQUEST)
        mViewRequest.isHidden = !(mOrder.status == Order.STATUS_REQUEST)
        
        // show/hide driver info
        mViewDriver.isHidden = (mOrder.status == Order.STATUS_REQUEST)
    }
    
    @IBAction func onButDriver(_ sender: Any) {
        // go to driver profile page
        let profileVC = DriverProfileViewController(nibName: "DriverProfileViewController", bundle: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func onButDriverChat(_ sender: Any) {
        // go to chat page
        let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func onButCancel(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func showMyLocation(location: CLLocationCoordinate2D?, updateForce: Bool = false) -> Bool {
        if !super.showMyLocation(location: location, updateForce: updateForce) {
            return false
        }
        
        if location == nil {
            return false
        }
        
        if !updateForce {
            // fill address in from
            let geocoder = GMSGeocoder()
            
            geocoder.reverseGeocodeCoordinate(location!) { response , error in
                if let address = response?.firstResult() {
                    let lines = address.lines! as [String]
                    let currentAddress = lines.joined(separator: " ")
                    
                    // fill address in from location
                    self.mTextLocationFrom.text = currentAddress
                    
                    //
                    // set from place
                    //
                    let pFrom = GooglePlace()
                    pFrom.name = currentAddress
                    
                    // city
                    if let city = address.locality {
                        pFrom.city = city
                    }
                    else if let country = address.country {
                        pFrom.city = country
                    }
                    
                    pFrom.location = location
                    
                    self.mOrder.from = pFrom
                }
                
                self.updateFromMark()
            }
        }
        
        return true
    }
    
    /// update "from marker" on the map
    ///
    /// - Parameter location: <#location description#>
    func updateFromMark() {
        mMarkerFrom?.map = nil
        
        if let l = mOrder.from?.location {
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
        
        if let l = mOrder.to?.location {
            mMarkerTo = GMSMarker()
            mMarkerTo?.icon = UIImage(named: "MainLocationTo")
            mMarkerTo?.position = l
            mMarkerTo?.map = mViewMap
        }
    }
    
    /// update map camera based on from & to locations
    ///
    /// - Parameter location: <#location description#>
    func updateMapCamera() {
        
        if let coordFrom = mOrder.from?.location, let coordTo = mOrder.to?.location {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(coordFrom)
            bounds = bounds.includingCoordinate(coordTo)

            if mOrder.status == Order.STATUS_REQUEST {
                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(140 + 96, 20, 60 + 70 + 20, 20))
                mViewMap.animate(with: update)
                
                // update price
                ApiManager.shared().googleMapGetDistance(pointFrom: coordFrom, pointTo: coordTo, completion: {(data, error) in
                    if let element = data {
                        //
                        // calculate taxi fee
                        //
                        
                        let serviceFee = 2.0
                        let baseFee = 2.0
                        let perMile = 1.8
                        let perMinute = 0.6
                        
                        let distance = element["distance"]["value"].int
                        let duration = element["duration"]["value"].int
                        
                        print("distance: \(distance)")
                        
                        var dFee = baseFee
                        if let dist = distance {
                            dFee += perMile * (Double(dist) / 1609.34)
                        }
                        if let dur = duration {
                            dFee += perMinute * (Double(dur) / 1609.34)
                        }
                        
                        self.price = dFee * Config.feeRate
                    }
                })
            }
            else {
                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(140 + 10, 20, 170 + 40, 20))
                mViewMap.animate(with: update)
                
                // draw a road path
            }
        
            return
        }

        moveCameraToLocation(mOrder.from?.location)
        moveCameraToLocation(mOrder.to?.location)
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

extension MainUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == mTextSearch {
            // go to full screen place autocomplete
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            
            autocompleteController.navigationController?.navigationBar.barTintColor = UIColor.black
            autocompleteController.navigationController?.navigationBar.tintColor = UIColor.black
            
            // nav bar tint color
            present(autocompleteController, animated: true, completion: nil)
        }
        else if textField == mTextLocationFrom {
            present(placePickerFrom!, animated: true, completion: nil)
        }
        else if textField == mTextLocationTo {
            present(placePickerTo!, animated: true, completion: nil)
        }
        
        return false
    }
}

extension MainUserViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // update place name
        mTextSearch.text = place.name
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        
        // update map
        if (showMyLocation(location: place.coordinate, updateForce: true)) {
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension MainUserViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place location \(place.coordinate.latitude), \(place.coordinate.longitude)")
        
        if viewController == placePickerFrom {
            self.mTextLocationFrom.text = place.formattedAddress
            mOrder.from = GooglePlace(place: place)
        }
        else if viewController == placePickerTo {
            self.mTextLocationTo.text = place.formattedAddress
            mOrder.to = GooglePlace(place: place)
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
}

// MARK: - Wait dialog Popup
extension MainUserViewController: PopupDelegate {
    func onClosePopup(_ sender: Any?) {
        let userCurrent = User.currentUser!
        let dbRef = FirebaseManager.ref()
        
        // remove order in "request" table
        dbRef.child(Order.TABLE_NAME_REQUEST).child(userCurrent.id).removeValue()

        if self.drivers.count > 0 {
            for d in self.drivers {
                // remove mark from "accepts" table
                dbRef.child(Order.TABLE_NAME_ACCEPT + "/" + d.id + "/" + userCurrent.id).removeValue()
            }
        }
        else {
            // no drivers found
            alertOk(title: "No drivers found",
                    message: "You can try later or move your position",
                    cancelButton: "OK",
                    cancelHandler: nil)
            
            return
        }
        
        // cancel waiting for drivers accept
        mqueryAccept?.removeAllObservers()
        
        // check variety of current selected driver
        guard let driverCurrent = self.selectedDriver else {
            // show notice when time out
            if sender == nil {
                // no drivers accept
                alertOk(title: "No driver accept your ride",
                        message: "You can try later or move your position",
                        cancelButton: "OK",
                        cancelHandler: nil)
            }
            
            return
        }
        
        // check current order
        if mOrder.isEmpty() {
            return
        }
        
        // remove mark from "accepts" table totally
        dbRef.child(Order.TABLE_NAME_ACCEPT + "/" + driverCurrent.id).removeValue()
        mOrder.driverId = driverCurrent.id
        
        // add request to "picked" table
        self.mOrder.saveToDatabaseRaw(path: Order.TABLE_NAME_PICKED + "/" + userCurrent.id)
        self.mOrder.saveToDatabaseRaw(path: Order.TABLE_NAME_PICKED + "/" + driverCurrent.id)

        updateOrder()
    }
}
