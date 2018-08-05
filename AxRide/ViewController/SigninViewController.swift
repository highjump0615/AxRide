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
    }
    
    @IBAction func onButGoogle(_ sender: Any) {
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
