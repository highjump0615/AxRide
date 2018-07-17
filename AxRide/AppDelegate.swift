//
//  AppDelegate.swift
//  AxRide
//
//  Created by Administrator on 7/13/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // google map initialization
        GMSServices.provideAPIKey(Config.googleMapApiKey)
        GMSPlacesClient.provideAPIKey(Config.googleMapApiKey)
        
        //
        // init status bar
        //
        UIApplication.shared.statusBarView?.backgroundColor = Constants.gColorPurple
        
        //
        // init navigation bar
        //
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        // nav bar back icon
        let backImage = UIImage(named: "ButBack")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        
        let nav = UINavigationController()
        
        goToSigninView(nav: nav)
        
        return true
    }
    
    func goToSigninView(nav: UINavigationController) {
        // if tutorial has been read, go to log in page directly
        if let tutorial = UserDefaults.standard.value(forKey: OnboardViewController.KEY_TUTORIAL) as? Bool, tutorial == true {
            let signinVC = SigninViewController(nibName: "SigninViewController", bundle: nil)
            nav.setViewControllers([signinVC], animated: true)
            UIApplication.shared.delegate?.window??.rootViewController = nav
        }
        else {
            let onboardVC = OnboardViewController(nibName: "OnboardViewController", bundle: nil)
            nav.setViewControllers([onboardVC], animated: true)
            UIApplication.shared.delegate?.window??.rootViewController = nav
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

