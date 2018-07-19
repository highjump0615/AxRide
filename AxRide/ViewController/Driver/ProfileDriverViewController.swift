//
//  ProfileDriverViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileDriverViewController: BaseViewController {
    
    private let CELLID_USER = "ProfileDriverUserCell"
    private let CELLID_RATE = "ProfileDriverRateCell"
    
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init table view
        mTableView.register(UINib(nibName: "ProfileDriverUserCell", bundle: nil), forCellReuseIdentifier: CELLID_USER)
        mTableView.register(UINib(nibName: "ProfileDriverRateCell", bundle: nil), forCellReuseIdentifier: CELLID_RATE)
        
        // right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ButProfileEdit"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onButEdit))
        
        showNavbar(transparent: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Profile"
    }
 
    /// edit profile
    @objc func onButEdit() {
        let editProfileVC = SignupProfileViewController(nibName: "SignupProfileViewController", bundle: nil)
        editProfileVC.type = SignupProfileViewController.FROM_PROFILE
        self.navigationController?.pushViewController(editProfileVC, animated: true)
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

extension ProfileDriverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellItem: UITableViewCell?
        
        if indexPath.row == 0 {
            // user info
            let cellUser = tableView.dequeueReusableCell(withIdentifier: CELLID_USER) as! ProfileDriverUserCell
            cellItem = cellUser
            
            cellItem?.selectionStyle = .none
        }
        else {
            // rate items
            let cellRate = tableView.dequeueReusableCell(withIdentifier: CELLID_RATE) as? ProfileDriverRateCell
            
            cellItem = cellRate
        }
        
        return cellItem!
    }
}

extension ProfileDriverViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
