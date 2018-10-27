//
//  SigninViewController.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class SigninViewController: BaseViewController {
    
    @IBOutlet weak var mViewEmail: UIView!
    @IBOutlet weak var mTextEmail: UITextField!
    @IBOutlet weak var mViewPassword: UIView!
    @IBOutlet weak var mTextPassword: UITextField!
    
    @IBOutlet weak var mButSignin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showNavbar()
        
        mViewEmail.backgroundColor = UIColor.clear
        mViewEmail.addBottomBorderWithColor(color: UIColor.white, width: 1.0)
        
        mViewPassword.backgroundColor = UIColor.clear
        mViewPassword.addBottomBorderWithColor(color: UIColor.white, width: 1.0)
        
        // placeholders
        mTextEmail.attributedPlaceholder = NSAttributedString(string: "Email",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        mTextPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        mButSignin.makeRound(r: 12.0)
        
        // keyboard avoiding
        KeyboardAvoiding.setAvoidingView(self.view, withTriggerView: mTextPassword)

        // google sign in initialization
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = "Sign In"
    }
    
    @IBAction func onButSignin(_ sender: Any) {
        var email = mTextEmail.text!
        var password = mTextPassword.text!
        
        self.view.endEditing(true)
        
        // trim white spaces
        email = email.trimmingCharacters(in: CharacterSet.whitespaces)
        password = password.trimmingCharacters(in: CharacterSet.whitespaces)
        
        //
        // check input validity
        //
        if email == "" {
            alertOk(title: "Email Invalid", message: "Please enter your email", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if password == "" {
            alertOk(title: "Password Invalid", message: "Please enter your password", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if !email.contains("@") || !Utils.isEmailValid(email: email){
            alertOk(title: "Email Invalid", message: "Please enter valid email address", cancelButton: "OK", cancelHandler: nil)
            return
        }
        
        // check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        // show loading view
        showLoadingView()
        
        // user authentication
        FirebaseManager.mAuth.signIn(withEmail: email, password: password, completion: { (result, error) in
            
            if let error = error {
                self.showLoadingView(show: false)
                
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                        self.alertForOtherCredential(email: email)
                    }
                    else {
                        self.alertOk(title: "Login Failed",
                                     message: error.localizedDescription,
                                     cancelButton: "OK",
                                     cancelHandler: nil)
                    }
                }
            }
            else {
                self.fetchUserInfo(userInfo: result?.user,
                                   firstName: nil,
                                   lastName: nil,
                                   photoURL: nil,
                                   onFailed: {
                                    FirebaseManager.signOut()
                                    self.showLoadingView(show: false)
                })
            }
        })
    }
    
    /// fetch user info with basic user auth
    ///
    /// - Returns: <#return value description#>
    func fetchUserInfo(userInfo: Firebase.User? = nil,
                       firstName: String?,
                       lastName: String?,
                       photoURL: String?,
                       onFailed: @escaping(() -> ()) = {},
                       onCompleted: @escaping(() -> ()) = {}) {
        
        guard let userId = FirebaseManager.mAuth.currentUser?.uid else {
            onFailed()
            return
        }
        
        User.readFromDatabase(withId: userId) { (u) in
            User.currentUser = u
            
            if User.currentUser == nil {
                // get user info, from facebook account info
                if userInfo != nil {
                    let newUser = User(withId: userId)
                    
                    newUser.email = (userInfo?.email)!
                    newUser.firstName = firstName!
                    newUser.lastName = lastName!
                    newUser.photoUrl = photoURL
                    
                    User.currentUser = newUser
                }
                
                // social login, go to u type page
                let profileVC = SignupProfileViewController(nibName: "SignupProfileViewController", bundle: nil)
                profileVC.type = SignupProfileViewController.FROM_SIGNUP
                self.navigationController?.setViewControllers([profileVC], animated: true)
            }
            else {
                self.goToMain()
            }
            
            onCompleted()
        }
    }
    
    @IBAction func onButForget(_ sender: Any) {
        // go to forget page
        let forgetVC = ForgetViewController(nibName: "ForgetViewController", bundle: nil)
        self.navigationController?.pushViewController(forgetVC, animated: true)
    }
    
    @IBAction func onButFacebook(_ sender: Any) {
        // check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        showLoadingView()
        
        let login = FBSDKLoginManager()
        login.logOut()
        
        login.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if let error = error {
                self.showLoadingView(show: false)
                self.alertOk(title: "Facebook Login Failed",
                             message: error.localizedDescription,
                             cancelButton: "OK",
                             cancelHandler: nil)
            }
            else if let cancelled = result?.isCancelled, cancelled {
                self.showLoadingView(show: false)
            }
            else if (FBSDKAccessToken.current() != nil){
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let req = FBSDKGraphRequest(graphPath: "me",
                                                   parameters: ["fields":"email,name,first_name,last_name,picture"],
                                                   tokenString: FBSDKAccessToken.current().tokenString,
                                                   version: nil,
                                                   httpMethod: "GET") {
                        req.start(completionHandler: { (connection, result, ferror) in
                            if(ferror == nil)
                            {
                                if let info = result as? [String:Any], let email = info["email"] as? String {
                                    let imageURL = "https://graph.facebook.com/\(String(describing: info["id"]!))/picture?type=normal"
                                    
                                    if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                                        if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                                            self.showLoadingView(show: false)
                                            self.alertForOtherCredential(email: email)
                                        }
                                        else {
                                            DispatchQueue.main.async {
                                                self.showLoadingView(show: false)
                                                self.alertOk(title: "Facebook Login Failed",
                                                             message: error.localizedDescription,
                                                             cancelButton: "OK",
                                                             cancelHandler: nil)
                                            }
                                        }
                                    }
                                    else {
                                        UserDefaults.standard.set("facebook", forKey: "lastSignedInMethod")
                                        self.fetchUserInfo(userInfo: user,
                                                           firstName: info["first_name"] as? String,
                                                           lastName: info["last_name"] as? String,
                                                           photoURL: imageURL,
                                                           onFailed: {
                                                            FirebaseManager.signOut()
                                                            self.showLoadingView(show: false)
                                        })
                                    }
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async {
                                    self.showLoadingView(show: false)
                                    self.alertOk(title: "Login Failed",
                                                 message: "Can not log in with facebook. Please try again.",
                                                 cancelButton: "OK",
                                                 cancelHandler: nil)
                                }
                            }
                        })
                    }
                    else {
                        DispatchQueue.main.async {
                            self.showLoadingView(show: false)
                            self.alertOk(title: "Login",
                                         message: "Can not log in with facebook. Please try again.",
                                         cancelButton: "OK",
                                         cancelHandler: nil)
                        }
                    }
                })
            }
            else {
                self.showLoadingView(show: false)
                print("Exception?")
            }
        }
    }
    
    @IBAction func onButGoogle(_ sender: Any) {
        // check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        showLoadingView()
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func onButSignup(_ sender: Any) {
        // go to signup page
        let signupEmailVC = SignupEmailViewController(nibName: "SignupEmailViewController", bundle: nil)
        self.navigationController?.pushViewController(signupEmailVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func alertForOtherCredential(email: String) {
        FirebaseManager.mAuth.fetchProviders(forEmail: email, completion: { (providers, error) in
            if error == nil {
                if providers?[0] == "google.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with Google. Please sign in with Google.", cancelButton: "OK", cancelHandler: nil)
                    }
                } else if providers?[0] == "facebook.com" {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with Facebook. Please sign in with Facebook.", cancelButton: "OK", cancelHandler: nil)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Login", message: "You already signed in with email. Please use email to log in.", cancelButton: "OK", cancelHandler: nil)
                    }
                }
            } else {
                
            }
        })
    }

}

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mTextEmail {
            mTextPassword.becomeFirstResponder()
        }
        else if textField == mTextPassword {
            textField.resignFirstResponder()
            onButSignin(textField)
        }
        
        return true
    }
}

extension SigninViewController : GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showLoadingView(show: false)
            
            alertOk(title: "Google Signin Failed",
                    message: error.localizedDescription,
                    cancelButton: "OK",
                    cancelHandler: nil)
            
            return
        }
        
        let email = user.profile.email
        let firstName = user.profile.givenName ?? " "
        let lastName = user.profile.familyName ?? " "
        let picture = user.profile.imageURL(withDimension: 400).absoluteString
        
        Auth.auth().fetchProviders(forEmail: email!, completion: { (providers, error) in
            
            if error == nil {
                
                if let provider = providers?[0], provider != "google.com" {
                    let providerName = (provider == "facebook.com" ? "Facebook" : "Email")
                    self.showLoadingView(show: false)
                    
                    self.alert(title: "Google Signin",
                               message: "Sign in with Google will replace your previous \(providerName) signin. Are you sure want to proceed?", okButton: "OK",
                               cancelButton: "Cancel",
                               okHandler: { (_) in
                                self.showLoadingView()
                                self.continueGoogleSignIn(user: user,
                                                          email: email!,
                                                          firstName: firstName,
                                                          lastName: lastName,
                                                          photoURL: picture)
                    }, cancelHandler: nil)
                    
                    return
                }
            }
            self.continueGoogleSignIn(user:user,
                                      email: email!,
                                      firstName: firstName,
                                      lastName: lastName,
                                      photoURL: picture)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func continueGoogleSignIn(user: GIDGoogleUser,
                              email: String,
                              firstName: String,
                              lastName: String,
                              photoURL: String) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            
            if let error = error {
                self.showLoadingView(show: false)
                
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    if errorCode == AuthErrorCode.accountExistsWithDifferentCredential {
                        self.alertForOtherCredential(email: email)
                    }
                    else {
                        self.alertOk(title: "Google Signin Failed",
                                     message: error.localizedDescription,
                                     cancelButton: "OK",
                                     cancelHandler: nil)
                    }
                    
                    return
                }
            }
            
            self.fetchUserInfo(userInfo: result?.user,
                               firstName: firstName,
                               lastName: lastName,
                               photoURL: photoURL,
                               onFailed: {
                                self.showLoadingView(show: false)
                                FirebaseManager.signOut()
            })
        }
    }
    
}

