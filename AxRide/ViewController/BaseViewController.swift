//
//  BaseViewController.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var mImgNavbarBg: UIImage?
    var mImgNavbarShadow: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = " "
    }
    
    func showNavbar(show: Bool = true, transparent: Bool = true, animated: Bool = false) {
        if transparent {
            // Sets background to a blank/empty image
            if mImgNavbarBg == nil {
                // save the original image to restore in colored navigation bar
                mImgNavbarBg = self.navigationController?.navigationBar.backgroundImage(for: .default)
            }
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            
            // Sets shadow (line below the bar) to a blank image
            if mImgNavbarShadow == nil {
                // save the original image to restore in colored navigation bar
                mImgNavbarShadow = self.navigationController?.navigationBar.shadowImage
            }
            self.navigationController?.navigationBar.shadowImage = UIImage()
            // Sets the translucent background color
            self.navigationController?.navigationBar.backgroundColor = .clear            
        }
        else {
            self.navigationController?.navigationBar.setBackgroundImage(mImgNavbarBg, for: .default)
            self.navigationController?.navigationBar.shadowImage = mImgNavbarShadow
            self.navigationController?.navigationBar.barTintColor = Constants.gColorPurple
        }
        
        self.navigationController?.setNavigationBarHidden(!show, animated: animated)
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
