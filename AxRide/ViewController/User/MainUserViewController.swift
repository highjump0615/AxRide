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
    
    
    static let RIDE_TYPE_NORMAL = 0
    static let RIDE_TYPE_SUV = 1
    static let RIDE_TYPE_SHARE = 2
    
    var mnRideType = RIDE_TYPE_NORMAL
    
    var placePickerFrom: GMSPlacePickerViewController?
    var placePickerTo: GMSPlacePickerViewController?
    
    var mCoordinateFrom: CLLocationCoordinate2D?
    var mCoordinateTo: CLLocationCoordinate2D?
    var mMarkerFrom: GMSMarker?
    var mMarkerTo: GMSMarker?
    
    private var mOrder: Order?
    var order: Order? {
        get { return mOrder}
        set {
            mOrder = newValue
            updateOrder()
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
        
        // markers
        mMarkerFrom = GMSMarker()
        mMarkerFrom?.icon = UIImage(named: "MainLocationFrom")
        mMarkerTo = GMSMarker()
        mMarkerTo?.icon = UIImage(named: "MainLocationTo")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
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
        let strAddrFrom = mTextLocationFrom.text
        mTextLocationFrom.text = mTextLocationTo.text
        mTextLocationTo.text = strAddrFrom
    }
    
    @IBAction func onButGo(_ sender: Any) {
        // go to profile page
        let foundVC = FoundDriverViewController(nibName: "FoundDriverViewController", bundle: nil)
        foundVC.homeVC = self
        
        let nav = UINavigationController()
        nav.setViewControllers([foundVC], animated: true)
        
        present(nav, animated: true, completion: nil)
    }
    
    func updateOrder() {
        if let o = order {
            // hide location & ride
            mViewLocation.isHidden = true
            mViewRide.isHidden = true
            mViewRequest.isHidden = true
            
            // show driver info
            mViewDriver.isHidden = false
        }
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

    override func showMyLocation(location: CLLocationCoordinate2D?, updateForce: Bool = false) {
        super.showMyLocation(location: location, updateForce: updateForce)
        
        if location == nil {
            return
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
                }
            }
            
            updateFromLocation(location: location!)
        }
    }
    
    func updateFromLocation(location: CLLocationCoordinate2D) {
        mCoordinateFrom = location
        mMarkerFrom?.position = location
        mMarkerFrom?.map = mViewMap
    }
    
    func updateToLocation(location: CLLocationCoordinate2D) {
        mCoordinateTo = location
        mMarkerTo?.position = location
        mMarkerTo?.map = mViewMap
    }
    
    /// update map camera based on from & to locations
    ///
    /// - Parameter location: <#location description#>
    func updateMapCamera(location: CLLocationCoordinate2D) {
        if mCoordinateFrom != nil && mCoordinateTo != nil {
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(mCoordinateFrom!)
            bounds = bounds.includingCoordinate(mCoordinateTo!)

            let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
            mViewMap.animate(with: update)
        }
        else {
            showMyLocation(location: location, updateForce: true)
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
        
        // update map
        showMyLocation(location: place.coordinate, updateForce: true)
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        
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
        print("Place attributions \(place.attributions)")
        
        if viewController == placePickerFrom {
            self.mTextLocationFrom.text = place.formattedAddress
            updateFromLocation(location: place.coordinate)
            
            // update camera
            updateMapCamera(location: mCoordinateFrom!)
            
        }
        else if viewController == placePickerTo {
            self.mTextLocationTo.text = place.formattedAddress
            updateToLocation(location: place.coordinate)
            
            // update camera
            updateMapCamera(location: mCoordinateTo!)
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
}
