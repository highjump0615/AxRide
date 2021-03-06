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
    var mViewRideMode: RideModeView?
    
    // location
    @IBOutlet weak var mTextSearch: UITextField!
    @IBOutlet weak var mTextLocationFrom: UITextField!
    @IBOutlet weak var mTextLocationTo: UITextField!
    
    @IBOutlet weak var mViewDriver: UIView!
    
    @IBOutlet weak var mButGo: UIButton!
    
    @IBOutlet weak var mLblPrice: UILabel!
    
    // driver info
    @IBOutlet weak var mLblDriverDistance: UILabel!
    @IBOutlet weak var mLblDriverName: UILabel!
    @IBOutlet weak var mLblDriverAddress: UILabel!
    @IBOutlet weak var mButCancel: UIButton!
    @IBOutlet weak var mButDriver: UIButton!
    
    
    var mnRideMode = Order.RIDE_MODE_NORMAL
    
    var placePickerFrom: GMSPlacePickerViewController?
    var placePickerTo: GMSPlacePickerViewController?
    
    var mMarkerDriver: GMSMarker?
    
    var mViewWaiting: UserWaitPopup?
    
    var drivers: [DriverStatus] = []
    var selectedDriver: DriverStatus?
    
    var mqueryAccept: DatabaseReference?
    var mqueryDriver: DatabaseReference?
    var mqueryNear: GFCircleQuery?
    var mqueryArrive: DatabaseReference?
    
    
    var price: Double {
        get {
            return mOrder!.fee
        }
        set {
            mOrder?.fee = newValue
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
        
        // clear driver info
        mLblDriverDistance.text = ""
        mLblDriverName.text = ""
        mLblDriverAddress.text = ""
        
        // placeholders
        mTextSearch.attributedPlaceholder = NSAttributedString(string: "Search",
                                                              attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLocationFrom.attributedPlaceholder = NSAttributedString(string: "My Current Location",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLocationTo.attributedPlaceholder = NSAttributedString(string: "Destination",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        
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
        
        // init ride mode view
        mViewRideMode = RideModeView.getView() as? RideModeView
        mViewRideMode?.delegate = self
        mViewRideMode?.updateRideView(mnRideMode)
        mViewRide.addSubview(mViewRideMode!)
        
        // init data
        mOrder = Order()
        
        // fetch current order
        getOrderInfo {
            // fetch current driver
            self.getDriverStatus()
        }
    }
    
    deinit {
        // remove observers
        mqueryDriver?.removeAllObservers()
        mqueryNear?.removeAllObservers()
        mqueryAccept?.removeAllObservers()
        mqueryArrive?.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switchNavbarColor(true)
        showNavbar(show: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateMap()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // clear map init mark
        self.isMapInited = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mViewRideMode?.frame = self.mViewRide.bounds
        mViewRideMode?.showView(true)
    }
    
    
    /// fetch current driver status
    func getDriverStatus() {
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)
        mqueryDriver = driverStatusRef.child(mOrder!.driverId)
        
        // query location change
        mqueryDriver?.observe(.value) { (snapshot) in
            // get current driver location
            geoFire.getLocationForKey(self.mOrder!.driverId) { (location, error) in
                self.showLoadingView(show: false)
                
                if let l = location {
                    var driver = self.selectedDriver
                    if driver == nil {
                        driver = DriverStatus()
                        driver?.id = self.mOrder!.driverId
                        self.selectedDriver = driver
                    }
                    
                    driver?.location = l
                    
                    // update driver mark on the map
                    self.updateDriverMark(location)
                }
            }
        }
    }
    
    func updateRideView() {
        mViewRideMode?.updateRideView(mnRideMode)
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
        let locationTemp = mOrder!.from
        mOrder!.from = mOrder!.to
        mOrder!.to = locationTemp

        // update map
        updateMap()
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
    
    /// Arrived destination
    private lazy var mListenerArrive: (DataSnapshot) -> Void = { snapshot in
        if !snapshot.exists() {
            return
        }
        
        guard let o = self.mOrder else {
            return
        }
        
        // go to payment page
        let payVC = PaymentViewController(nibName: "PaymentViewController", bundle: nil)
        payVC.order = o
        self.navigationController?.pushViewController(payVC, animated: true)
    }
    
    @IBAction func onButGo(_ sender: Any) {
        let userCurrent = User.currentUser!
        
        // add request to "request" table
        self.mOrder!.customerId = userCurrent.id
        if let coord = self.mCoordinate {
            self.mOrder!.latitude = coord.latitude
            self.mOrder!.longitude = coord.longitude
        }
        self.mOrder!.saveToDatabase(withID: userCurrent.id)
        
        //
        // show loading
        //
        mViewWaiting?.frame = self.view.bounds
        mViewWaiting?.showView(true, animated: true)
        mViewWaiting?.startTimer()
        
        // clear driver list
        drivers.removeAll()
        
        //
        // load drivers near around
        //
        let driverStatusRef = FirebaseManager.ref().child(DriverStatus.TABLE_NAME)
        let geoFire = GeoFire(firebaseRef: driverStatusRef)

        // get current location
        var dLatitude = self.mOrder!.from?.location?.latitude
        var dLongitude = self.mOrder!.to?.location?.latitude
        if let coord = self.mCoordinate {
            dLatitude = coord.latitude
            dLongitude = coord.longitude
        }
        
        mqueryNear = geoFire.query(at: CLLocation(latitude: dLatitude!,
                                                  longitude: dLongitude!),
                                   withRadius: Constants.MAX_DISTANCE)
        
        mqueryNear?.observe(.keyEntered) { (key, location) in
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
        
        mqueryNear?.observeReady {
            print("ready")
        }
        
        // wait for drivers accept
        mqueryAccept = FirebaseManager.ref().child(Order.TABLE_NAME_REQUEST).child(userCurrent.id).child(Order.FIELD_DRIVERID)
        mqueryAccept?.observe(.value, with: mListenerDriver)
    }
    
    override func updateMapCamera() {
        super.updateMapCamera()
        
        guard let order = mOrder else {
            return
        }
        
        if order.status > Order.STATUS_REQUEST {
            return
        }
        
        if let coordFrom = order.from?.location, let coordTo = order.to?.location {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(coordFrom)
            bounds = bounds.includingCoordinate(coordTo)
            
            if order.status == Order.STATUS_REQUEST {
                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(140 + 96, 20, 60 + 70 + 20, 20))
                mViewMap.animate(with: update)
                
                // update price
                ApiManager.shared().googleMapGetDistance(pointFrom: coordFrom, pointTo: coordTo, completion: {(data, error) in
                    if let element = data {
                        //
                        // calculate taxi fee
                        //
                        
                        let serviceFee = 2.0
                        var baseFee = 0.83
                        var perMile = 0.66
                        var perMinute = 0.14
                        
                        // 6 seats
                        if (order.rideMode == Order.RIDE_MODE_SUV) {
                            baseFee = 2.07
                            perMile = 1.08
                            perMinute = 0.22
                        }
                        
                        let distance = element["distance"]["value"].int
                        let duration = element["duration"]["value"].int
                        
                        print("distance: \(distance)")
                        
                        var dFee = baseFee
                        if let dist = distance {
                            dFee += perMile * (Double(dist) / Constants.MILE_DIST)
                        }
                        if let dur = duration {
                            dFee += perMinute * (Double(dur) / Constants.MILE_DIST)
                        }
                        
                        self.price = dFee
                    }
                })
            }
        }
    }
        
    /// update page based on order status
    override func updateOrder() {
        super.updateOrder()
        
        // show/hide location & ride
        mViewLocation.isHidden = !(mOrder!.status == Order.STATUS_REQUEST)
        mViewRide.isHidden = !(mOrder!.status == Order.STATUS_REQUEST)
        mViewRequest.isHidden = !(mOrder!.status == Order.STATUS_REQUEST)
        
        // show/hide driver info
        mViewDriver.isHidden = (mOrder!.status == Order.STATUS_REQUEST)
        
        // order has not started, exit
        if mOrder!.status == Order.STATUS_REQUEST {
            return
        }
        
        // fetch driver
        if mOrder!.driver == nil {
            User.readFromDatabase(withId: mOrder!.driverId) { (user) in
                self.mOrder!.driver = user
                
                // update driver info
                self.updateDriverInfo()
            }
        }
        
        // wait for arrive
        let userCurrent = User.currentUser!
        mqueryArrive = FirebaseManager.ref().child(Order.TABLE_NAME_ARRIVED).child(userCurrent.id)
        mqueryArrive?.observe(.value, with: mListenerArrive)
    }
    
    /// update UI for driver info
    func updateDriverInfo() {
        guard let d = mOrder!.driver else {
            return
        }
        
        updateDistance(mCoordinate)
        
        let strRating = d.userRate().format(f: ".1")
        mLblDriverName.text = "\(d.userFullName())    \(strRating)"
        mLblDriverAddress.text = d.location
        
        // photo
        if let photoUrl = d.photoUrl {
            mButDriver.sd_setImage(with: URL(string: photoUrl),
                                   for: .normal,
                                   placeholderImage: UIImage(named: "UserDefault"),
                                   options: .progressiveDownload,
                                   completed: nil)
        }
    }
    
    func updateDistance(_ location: CLLocationCoordinate2D?) {
        // calculate distance
        if let from = location, let to = mOrder!.to?.location {
            let locationFrom = CLLocation(latitude: from.latitude, longitude: from.longitude)
            let locationTo = CLLocation(latitude: to.latitude, longitude: to.longitude)
            let dist = locationTo.distance(from: locationFrom) / 1000.0
            
            mLblDriverDistance.text = "\(dist.format(f: ".1")) km"
        }
    }
    
    @IBAction func onButDriver(_ sender: Any) {
        guard let d = mOrder!.driver else {
            return
        }
        
        // go to profile page
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.user = d
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func onButDriverChat(_ sender: Any) {
        guard let d = mOrder!.driver else {
            return
        }
        
        // go to chat page
        let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
        chatVC.userTo = d
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func onButCancel(_ sender: Any) {
        self.alert(title: "Are you sure to cancel this ride?",
                   message: "You may have unnecessary financial lost",
                   okButton: "OK",
                   cancelButton: "Cancel",
                   okHandler: { (_) in
                    self.doCancelRide()
        }, cancelHandler: nil)
    }
    
    /// cancel ride
    func doCancelRide() {
        // clear data in database
        mOrder?.clearFromDatabase()
        
        // clear order
        mOrder = Order()
        let _ = showMyLocation(location: mCoordinate, updateForce: true)
        
        updateOrder()
        
        // clear map
        mViewMap.clear()
        updateMap()

        // clear observe driver
        mqueryDriver?.removeAllObservers()
    }
    
    /// finish current order
    func finishOrder() {
        mOrder = Order()
        
        self.drivers.removeAll()
        self.selectedDriver = nil
        
        updateMap()
        updateOrder()
        
        setFromAddress(mCoordinate)
        updateDriverMark(nil)
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
        updateDistance(location)
        
        if !super.showMyLocation(location: location, updateForce: updateForce) {
            return false
        }
        
        if location == nil {
            return false
        }
        
        setFromAddress(mCoordinate ?? location)
        
        return true
    }
    
    func setFromAddress(_ location: CLLocationCoordinate2D?) {
        if location == nil {
            return
        }
        
        // set as "from" location if not set
        if self.mOrder!.from == nil {
            // fill address in from
            let geocoder = GMSGeocoder()
            
            geocoder.reverseGeocodeCoordinate(location!) { response , error in
                if let address = response?.firstResult() {
                    let lines = address.lines! as [String]
                    let currentAddress = lines.joined(separator: " ")
                    
                    // fill address in from location
                    self.mTextLocationFrom.text = currentAddress
                    
                    // check again, as it took time to fetch address
                    if self.mOrder!.from == nil {
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
                        
                        self.mOrder!.from = pFrom
                        self.updateFromMark()
                        
                        return
                    }
                }
            }
        }
    }
    
    /// update driver marker on the map
    func updateDriverMark(_ location: CLLocation?) {
        if mMarkerDriver == nil {
            mMarkerDriver = GMSMarker()
            mMarkerDriver?.icon = UIImage(named: "MainDriverMark")
            mMarkerDriver?.map = mViewMap
        }
        
        if let l = location {
            mMarkerDriver?.position = l.coordinate
        }
        else {
            // remove driver mark
            mMarkerDriver?.map = nil
        }
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
            switchNavbarColor(false)
            present(autocompleteController, animated: true, completion: nil)
        }
        else if textField == mTextLocationFrom {
            switchNavbarColor(false)
            present(placePickerFrom!, animated: true, completion: nil)
        }
        else if textField == mTextLocationTo {
            switchNavbarColor(false)
            present(placePickerTo!, animated: true, completion: nil)
        }
        
        return false
    }
    
    func switchNavbarColor(_ isWhite: Bool) {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : isWhite ? UIColor.white : Constants.gColorPurple]
        UINavigationBar.appearance().tintColor = isWhite ? UIColor.white : Constants.gColorPurple
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
            mOrder!.from = GooglePlace(place: place)
        }
        else if viewController == placePickerTo {
            self.mTextLocationTo.text = place.formattedAddress
            mOrder!.to = GooglePlace(place: place)
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
}

// MARK: - Ride Mode view
extension MainUserViewController: RideModeDelegate {
    func onChangeMode(_ mode: Int) {
        mnRideMode = mode
    }
}

// MARK: - Wait dialog Popup
extension MainUserViewController: PopupDelegate {
    func onClosePopup(_ sender: Any?) {
        // cancel finding near driver
        mqueryNear?.removeAllObservers()
        
        // cancel waiting for drivers accept
        mqueryAccept?.removeAllObservers()
        
        let userCurrent = User.currentUser!
        let dbRef = FirebaseManager.ref()
        
        // remove order in "request" table
        mOrder?.removeFromDatabase()

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
        if mOrder!.isEmpty() {
            return
        }
        
        // remove mark from "accepts" table totally
        dbRef.child(Order.TABLE_NAME_ACCEPT + "/" + driverCurrent.id).removeValue()
        mOrder!.driverId = driverCurrent.id
        
        // add request to "picked" table
        self.mOrder!.saveToDatabaseRaw(path: Order.TABLE_NAME_PICKED + "/" + userCurrent.id)
        self.mOrder!.saveToDatabaseRaw(path: Order.TABLE_NAME_PICKED + "/" + driverCurrent.id)

        updateMap()
        updateOrder()
    }
}
