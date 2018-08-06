//
//  SignupProfileViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Firebase
import IHKeyboardAvoiding
import SDWebImage

class SignupProfileViewController: BaseViewController {
    
    static let FROM_SIGNUP = 0
    static let FROM_PROFILE = 1
    
    var email: String?
    var password: String?
    
    var type = SignupProfileViewController.FROM_SIGNUP
    
    @IBOutlet weak var mButPhoto: UIButton!
    
    @IBOutlet weak var mTextName: UITextField!
    @IBOutlet weak var mTextLastName: UITextField!
    @IBOutlet weak var mTextLocation: UITextField!
    @IBOutlet weak var mTextContact: UITextField!
    
    @IBOutlet weak var mButNext: UIButton!
    
    var avatarLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // placeholders
        mTextName.attributedPlaceholder = NSAttributedString(string: "Name",
                                                              attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLastName.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                             attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextLocation.attributedPlaceholder = NSAttributedString(string: "Location",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])
        mTextContact.attributedPlaceholder = NSAttributedString(string: "Contact",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: Constants.gColorGray])

        mButPhoto.makeRound()
        
        // next button
        mButNext.makeRound(r: 12.0)
        
        if type == SignupProfileViewController.FROM_PROFILE {
            mButNext.setTitle("Save", for: .normal)
        }
        else {
            mButNext.setTitle("Next", for: .normal)
        }
        
        // keyboard avoiding
        KeyboardAvoiding.setAvoidingView(self.view, withTriggerView: mTextContact)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // title
        self.title = "User Profile"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButPhoto(_ sender: Any) {
        selectImageFromPicker()
    }
    
    @IBAction func onButNext(_ sender: Any) {
        let _firstName = getFirstName()
        let _lastName = getLastName()
        
        if _firstName.isEmpty {
            self.alertOk(title: "First Name Invalid",
                         message: "First name cannot be empty",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        if !Utils.isNameValid(name: _firstName) {
            self.alertOk(title: "First Name Invalid",
                         message: "First name can only be normal charaters",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        
        if _lastName.isEmpty {
            self.alertOk(title: "Last Name Invalid",
                         message: "Last name cannot be empty",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        if !Utils.isNameValid(name: _lastName) {
            self.alertOk(title: "Last Name Invalid",
                         message: "Last name can only be normal charaters",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        
        if User.currentUser == nil {
            //
            // sign up new user
            //
            
            // show loading view
            showLoadingView()
            
            FirebaseManager.mAuth.createUser(withEmail: email!, password: password!, completion: { (result, error) in
                if let error = error {
                    // hide loading view
                    self.showLoadingView(show: false)
                    
                    self.alertOk(title: "Sign up Failed",
                                 message: error.localizedDescription,
                                 cancelButton: "OK",
                                 cancelHandler: nil)
                    return
                }
                
                // set user
                let userNew = User(withId: (result?.user.uid)!)
                
                // save user info
                userNew.email = self.email!
                User.currentUser = userNew
                
                self.uploadImageAndSetupUserInfo()
            })
        }
        else {
            uploadImageAndSetupUserInfo()
        }
    }
    
    func uploadImageAndSetupUserInfo() {
        // upload photo
        let user = User.currentUser!
        if avatarLoaded, let image = self.mButPhoto.image(for: .normal) {
            showLoadingView()
            
            let path = "users / " + user.id + ".png"
            
            let resized = image.resized(toWidth: 200, toHeight: 200)
            FirebaseManager.uploadImageTo(path: path, image: resized, completionHandler: { (downloadURL, error) in
                if let error = error {
                    self.showLoadingView(show: false)
                    self.alertOk(title: "Failed Uploading Photo",
                                 message: error.localizedDescription,
                                 cancelButton: "OK",
                                 cancelHandler: nil)
                    return
                }
                
                if let url = downloadURL {
                    User.currentUser?.photoUrl = url
                    
                    // save image to cache
                    SDWebImageManager.shared().saveImage(toCache: resized,
                                                         for: URL(string: url))
                }
                
                self.saveUserInfo()
            })
        }
        else {
            self.saveUserInfo()
        }
    }
    
    /// save user data into db
    ///
    /// - Parameter imageURL: <#imageURL description#>
    func saveUserInfo() {
        let user = User.currentUser
        
        // save info
        user?.firstName = getFirstName()
        user?.lastName = getLastName()
        
        user?.saveToDatabase()
        
        // hide loading
        showLoadingView(show: false)
        
        if type == SignupProfileViewController.FROM_PROFILE {
            // edit profile page
            self.navigationController?.popViewController(animated: true)
        }
        else {
            // signup profile page
            // go to signup choose page
            let signupChooseVC = SignupChooseViewController(nibName: "SignupChooseViewController", bundle: nil)
            self.navigationController?.pushViewController(signupChooseVC, animated: true)
        }
    }
    
    /// retrieve first name with white space removed
    ///
    /// - Returns: <#return value description#>
    func getFirstName() -> String {
        let strText = mTextName.text!
        return strText.trimmingCharacters(in: .whitespaces)
    }
    
    /// retrieve first name with white space removed
    ///
    /// - Returns: <#return value description#>
    func getLastName() -> String {
        let strText = mTextLastName.text!
        return strText.trimmingCharacters(in: .whitespaces)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectImageFromPicker() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            UIViewController.takePhoto(viewController: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Select from gallery", style: .default, handler: { (action) in
            UIViewController.loadFromGallery(viewController: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension SignupProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mTextName {
            mTextLastName.becomeFirstResponder()
        }
        else if textField == mTextLastName {
            mTextLocation.becomeFirstResponder()
        }
        else if textField == mTextLocation {
            mTextContact.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            onButNext(textField)
        }
        
        return true
    }
    
}

extension SignupProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            mButPhoto.setImage(chosenImage, for: .normal)
            avatarLoaded = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
