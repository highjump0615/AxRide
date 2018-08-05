//
//  SignupEmailViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class SignupEmailViewController: BaseViewController {
    
    @IBOutlet weak var mViewEmail: UIView!
    @IBOutlet weak var mTextEmail: UITextField!
    @IBOutlet weak var mViewPassword: UIView!
    @IBOutlet weak var mTextPassword: UITextField!
    @IBOutlet weak var mViewRePassword: UIView!
    @IBOutlet weak var mTextRePassword: UITextField!
    
    @IBOutlet weak var mButNext: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mViewEmail.backgroundColor = UIColor.clear
        mViewEmail.addBottomBorderWithColor(color: UIColor.white, width: 1.0)
        
        mViewPassword.backgroundColor = UIColor.clear
        mViewPassword.addBottomBorderWithColor(color: UIColor.white, width: 1.0)
        
        mViewRePassword.backgroundColor = UIColor.clear
        mViewRePassword.addBottomBorderWithColor(color: UIColor.white, width: 1.0)
        
        // placeholders
        mTextEmail.attributedPlaceholder = NSAttributedString(string: "Email",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        mTextPassword.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        mTextRePassword.attributedPlaceholder = NSAttributedString(string: "Re-enter Password",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        mButNext.makeRound(r: 12.0)
        
        // keyboard avoiding
        KeyboardAvoiding.setAvoidingView(self.view, withTriggerView: mTextRePassword)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = "Sign Up"
    }
    
    @IBAction func onButNext(_ sender: Any) {
        
        var email = mTextEmail.text!
        var password = mTextPassword.text!
        var passwordConfirm = mTextRePassword.text!
        
        self.view.endEditing(true)
        
        // trim white spaces
        email = email.trimmingCharacters(in: CharacterSet.whitespaces)
        password = password.trimmingCharacters(in: CharacterSet.whitespaces)
        passwordConfirm = passwordConfirm.trimmingCharacters(in: CharacterSet.whitespaces)
        
        //
        // check input validity
        //
        if email == "" {
            alertOk(title: "Email Invalid", message: "Please enter your email", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if !email.contains("@") || !Utils.isEmailValid(email: email){
            alertOk(title: "Email Invalid", message: "Please enter valid email address", cancelButton: "OK", cancelHandler: nil)
            return
        }
        if password == "" {
            alertOk(title: "Password Invalid",
                    message: "Please enter your password",
                    cancelButton: "OK",
                    cancelHandler: nil)
            return
        }
        if password != passwordConfirm {
            alertOk(title: "Password Invalid",
                    message: "Confirm password does not match",
                    cancelButton: "OK",
                    cancelHandler: nil)
            return
        }
        
        // check connection
        if Constants.reachability.connection == .none {
            showConnectionError()
            return
        }
        
        // show loading view
        showLoadingView()
        
        // check if email has been used
        let database = FirebaseManager.ref()
        let query = database.child(User.TABLE_NAME)
        query.queryOrdered(byChild: User.FIELD_EMAIL)
            .queryEqual(toValue: "\(email)")
            .observeSingleEvent(of: .value, with: {snapshot in
                // hide loading view
                self.showLoadingView(show: false)
                
                if snapshot.exists() {
                    // existing
                    self.alertOk(title: "Email is already in use",
                                 message: "Please enter other email address",
                                 cancelButton: "OK",
                                 cancelHandler: nil)
                    return
                }
                
                // go to signup profile page
                let signupProfileVC = SignupProfileViewController(nibName: "SignupProfileViewController", bundle: nil)
                signupProfileVC.email = email
                signupProfileVC.password = password
                self.navigationController?.pushViewController(signupProfileVC, animated: true)
            })
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

extension SignupEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mTextEmail {
            mTextPassword.becomeFirstResponder()
        }
        else if textField == mTextPassword {
            mTextRePassword.becomeFirstResponder()
        }
        else if textField == mTextRePassword {
            textField.resignFirstResponder()
            onButNext(textField)
        }
        
        return true
    }
    
}

