//
//  SignupChooseViewController.swift
//  AxRide
//
//  Created by Administrator on 7/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class SignupChooseViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showNavbar()
        
        // title
        self.title = "Sign Up"
    }
    
    @IBAction func onButRider(_ sender: Any) {
        gotoTermView(type: UserType.customer)
    }
    
    @IBAction func onButDriver(_ sender: Any) {
        gotoTermView(type: UserType.driver)
    }
    
    func gotoTermView(type: UserType) {
        
        let userCurrent = User.currentUser!
        userCurrent.type = type
        userCurrent.saveToDatabase(withField: User.FIELD_TYPE, value: type.rawValue)
        
        // go to term page
        let termVC = TermViewController(nibName: "TermViewController", bundle: nil)
        self.navigationController?.pushViewController(termVC, animated: true)
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
