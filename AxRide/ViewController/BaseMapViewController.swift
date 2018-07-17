//
//  BaseMapViewController.swift
//  AxRide
//
//  Created by Administrator on 7/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import GoogleMaps

class BaseMapViewController: BaseViewController {
    
    let locationManager = CLLocationManager()
    var mLocation: CLLocation?

    @IBOutlet weak var mViewMap: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initLocation()
        initMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocation() {
        //
        // init location
        //
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.startUpdatingLocation()
    }
    
    func initMap() {
        mViewMap.isMyLocationEnabled = true
        mViewMap.settings.myLocationButton = true
        mViewMap.delegate = self
        
        showMyLocation(location: mViewMap.myLocation)
    }
    
    func showMyLocation(location: CLLocation?) {
        if mLocation != nil {
            // alredy showed my location, return
            return
        }
        
        if let l = location {
            let camera = GMSCameraPosition.camera(withLatitude: l.coordinate.latitude,
                                                  longitude: l.coordinate.longitude,
                                                  zoom: 16.0)
            mViewMap.camera = camera
            
            mLocation = l
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BaseMapViewController: CLLocationManagerDelegate {
    //
    // MARK: - CLLocationManagerDelegate
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        
        print("\(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        showMyLocation(location: location)
    }
}

extension BaseMapViewController: GMSMapViewDelegate {
}
