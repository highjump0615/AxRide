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

class MainDriverViewController: BaseHomeViewController {
    
    @IBOutlet weak var mSwitch: UISwitch!
    @IBOutlet weak var mViewInfo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewInfo.makeRound(r: 16)
        mSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        
        // empty title
        self.navigationItem.title = " "
        
        // broken state
        self.mSwitch.setOn(!User.currentUser!.broken, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar(show: false)
    }
    
    @IBAction func onSwitchChanged(_ sender: Any) {
        let userCurrent = User.currentUser!
        
        userCurrent.broken = !mSwitch.isOn
        userCurrent.saveToDatabase(withField: User.FIELD_BROKEN, value: userCurrent.broken)
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
