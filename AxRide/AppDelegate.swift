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
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Stripe
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var pendingUserId: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        STPPaymentConfiguration.shared().publishableKey = Config.stripeApiKey
        
        // google map initialization
        GMSServices.provideAPIKey(Config.googleMapApiKey)
        GMSPlacesClient.provideAPIKey(Config.googleMapApiKey)
        
        // firebase initialization
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // google sign-in initialization
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        // facebook initialization
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKSettings.setAppID(Config.facebookId)
        
        //
        // Register for remote notifications
        //
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //
        // init status bar
        //
        UIApplication.shared.statusBarView?.backgroundColor = Constants.gColorPurple
        
        //
        // init navigation bar
        //
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        
        // nav bar back icon
        let backImage = UIImage(named: "ButBack")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        
        let nav = UINavigationController()
        
        // go to home when logged in
        let userId = FirebaseManager.mAuth.currentUser?.uid
        if !Utils.isStringNullOrEmpty(text: userId) {
            // open splash screen temporately
            let splashVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.delegate?.window??.rootViewController = splashVC
            
            // check connection
            if Constants.reachability.connection == .none {
                self.goToSigninView(nav: nav)
            }
            else {
                // fetch user info
                User.readFromDatabase(withId: userId!) { (user) in
                    User.currentUser = user
                    
                    if user != nil {
                        // go to home page
                        if let homeVC = BaseViewController.getMainViewController() {
                            nav.setViewControllers([homeVC], animated: true)
                            UIApplication.shared.delegate?.window??.rootViewController = nav
                        }
                    }
                    else {
                        self.goToSigninView(nav: nav)
                    }
                }
            }
        }
        else {
            goToSigninView(nav: nav)
        }
        
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
        if let strUserId = self.pendingUserId {
            //
            // go to message page
            //
            let rootViewController = self.window!.rootViewController as! UINavigationController

            let chatVC = ChatViewController(nibName: "ChatViewController", bundle: nil)
            chatVC.userToId = strUserId
            rootViewController.pushViewController(chatVC, animated: true)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        if !handled {
            handled = GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: [:])
        }
        
        return handled
    }

}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("fcm token:\(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("fcm message received:\(remoteMessage.appData)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        
        self.processNotification(application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //        if let messageID = userInfo[gcmMessageIDKey] {
        //            print("Message ID: \(messageID)")
        //        }
        //
        // Print full message.
        self.processNotification(application, userInfo: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func processNotification(_ application: UIApplication,
                             userInfo: [AnyHashable: Any]) {
        print(userInfo)
        
        if application.applicationState != .active {
            // tapped notification from background
            self.pendingUserId = userInfo[Message.PN_FIELD_USER_ID] as? String
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
}

