//
//  ProfileViewController.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    private let CELLID_USER = "ProfileUserCell"
    private let CELLID_CARD = "ProfileCardCell"
    private let CELLID_LOCATION = "ProfileLocationCell"
    private let CELLID_EMPTY = "ProfileEmptyCell"
    
    static let LIST_TYPE_PAYMENT = 0
    static let LIST_TYPE_LOCATION = 1
    
    private var mnListType = ProfileViewController.LIST_TYPE_PAYMENT
    
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init table view
        mTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: mTableView.frame.width, height: 0.01))
        mTableView.register(UINib(nibName: "ProfileUserCell", bundle: nil), forCellReuseIdentifier: CELLID_USER)
        mTableView.register(UINib(nibName: "ProfileEmptyCell", bundle: nil), forCellReuseIdentifier: CELLID_EMPTY)
        
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
        
        // reload
        mTableView.reloadData()
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
    
    @objc func onButPaymentList(sender: UIButton) {
        mnListType = ProfileViewController.LIST_TYPE_PAYMENT
        
        mTableView.reloadData()
    }
    
    @objc func onButLocationList(sender: UIButton) {
        mnListType = ProfileViewController.LIST_TYPE_LOCATION
        
        mTableView.reloadData()
    }

}

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // user info
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellItem: UITableViewCell?
        
        if indexPath.section == 0 {
            // user info
            let cellUser = tableView.dequeueReusableCell(withIdentifier: CELLID_USER) as! ProfileUserCell
            cellUser.fillContent(user: User.currentUser)
            cellUser.updateListType(type: mnListType)
            
            // buttons
            cellUser.mButPayment.addTarget(self, action: #selector(onButPaymentList), for: .touchUpInside)
            cellUser.mButLocation.addTarget(self, action: #selector(onButLocationList), for: .touchUpInside)
            
            cellItem = cellUser
        }
        else {
            // empty notice
            let cellEmpty = tableView.dequeueReusableCell(withIdentifier: CELLID_EMPTY) as? ProfileEmptyCell
            cellEmpty?.fillContent(listType: mnListType)
            
            cellItem = cellEmpty
        }
        
        return cellItem!
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height: CGFloat = 0.0001
        
        // no footer in user cell
        if section == 0 {
            return height
        }
        
        // no footer in payment item cell
        if mnListType == ProfileViewController.LIST_TYPE_PAYMENT {
            return height
        }
        
        // footer in location item cell
        return 106
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UIView?
        
        if section == 1 {
            let viewHeader = ProfileCardListHeader.getView(listType: mnListType) as! ProfileCardListHeader
            viewHeader.showView(bShow: true, animated: false)
            
            view = viewHeader
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view: UIView?
        
        if section == 1 && mnListType == ProfileViewController.LIST_TYPE_LOCATION {
            let viewFooter = ProfileLocationListFooter.getView() as! ProfileLocationListFooter
            viewFooter.showView(bShow: true, animated: false)
            
            view = viewFooter
        }
        
        return view
    }
}
