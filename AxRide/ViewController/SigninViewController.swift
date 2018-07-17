//
//  SigninViewController.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

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
        // go to signup page
        let mainUserVC = MainUserViewController(nibName: "MainUserViewController", bundle: nil)
        self.navigationController?.setViewControllers([mainUserVC], animated: true)
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
