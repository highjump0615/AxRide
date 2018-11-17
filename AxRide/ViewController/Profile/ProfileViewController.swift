//
//  ProfileViewController.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Stripe
import GooglePlacePicker
import Firebase

class ProfileViewController: BaseViewController {
    
    private let CELLID_USER = "ProfileUserCell"
    private let CELLID_CARD = "ProfileCardCell"
    private let CELLID_LOCATION = "ProfileLocationCell"
    private let CELLID_EMPTY = "ProfileEmptyCell"
    
    static let LIST_TYPE_PAYMENT = 0
    static let LIST_TYPE_LOCATION = 1
    
    private var mnListType = ProfileViewController.LIST_TYPE_PAYMENT
    var user: User?
    
    var placePicker: GMSPlacePickerViewController?
    
    @IBOutlet weak var mTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init table view
        mTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: mTableView.frame.width, height: 0.01))
        mTableView.register(UINib(nibName: "ProfileUserCell", bundle: nil), forCellReuseIdentifier: CELLID_USER)
        mTableView.register(UINib(nibName: "ProfileEmptyCell", bundle: nil), forCellReuseIdentifier: CELLID_EMPTY)
        mTableView.register(UINib(nibName: "ProfileCardCell", bundle: nil), forCellReuseIdentifier: CELLID_CARD)
        mTableView.register(UINib(nibName: "ProfileLocationCell", bundle: nil), forCellReuseIdentifier: CELLID_LOCATION)
        
        // current user as default
        if self.user == nil {
            self.user = User.currentUser
            
            // right bar button
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ButProfileEdit"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(onButEdit))
        }
        
        showNavbar(transparent: false)
        
        //
        // init stripe card list
        //
        if self.user!.stripeCards == nil {
            StripeApiManager.shared().getCardsList(customerId: self.user!.stripeCustomerId) { (result) in
                guard let result = result else {
                    return
                }
                
                for cardInfo in result {
                    let cardNew = Card()
                    cardNew.last4 = cardInfo["last4"] as! String
                    
                    if let brand = cardInfo["brand"] as? String {
                        cardNew.brand = STPCard.brand(from: brand)
                    }
                    
                    // add card to list
                    self.user?.addStripeCard(cardNew)
                }
                
                self.mTableView.reloadData()
            }
        }

        //
        // int place picker
        //
        let config = GMSPlacePickerConfig(viewport: nil)
        self.placePicker = GMSPlacePickerViewController(config: config)
        self.placePicker?.delegate = self
        
        //
        // init addresses
        //
        if self.user!.addresses == nil {
            let dbRef = FirebaseManager.ref()
            
            let query = dbRef.child(Address.TABLE_NAME).child(self.user!.id)
            query.observeSingleEvent(of: .value) { (snapshot) in
                // order not found
                if !snapshot.exists() {
                    return
                }
                
                for addr in snapshot.children {
                    let a = Address(snapshot: addr as! DataSnapshot)
                    self.user!.addAddress(a)
                }
                
                self.mTableView.reloadData()
            }
        }
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
    
    @objc func onButAddCard(sender: UIButton) {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    @objc func onButAddLocation(sender: UIButton) {
        present(self.placePicker!, animated: true, completion: nil)
    }
    
    func doDeleteAddress(_ index: Int) {
        // remove from user info
        if let user = self.user, let addr = user.addresses?[index] {
            addr.removeFromDatabase(user.id)
            user.addresses?.remove(at: index)
            
            // remove from table
            mTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .bottom)
        }
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

        // drivers don't show this temporarily
        if self.user?.type == UserType.driver {
            return 0
        }
        else {
            if mnListType == ProfileViewController.LIST_TYPE_PAYMENT {
                if let cards = self.user?.stripeCards {
                    // if no cards, show no content cell
                    return max(cards.count, 1)
                }
            }
            else {
                if let locations = self.user?.addresses {
                    // if no locations, show no content cell
                    return max(locations.count, 1)
                }
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellItem: UITableViewCell?
        
        if indexPath.section == 0 {
            // user info
            let cellUser = tableView.dequeueReusableCell(withIdentifier: CELLID_USER) as! ProfileUserCell
            cellUser.fillContent(user: self.user!)
            cellUser.updateListType(type: mnListType)
            
            // buttons
            cellUser.mButPayment.addTarget(self, action: #selector(onButPaymentList), for: .touchUpInside)
            cellUser.mButLocation.addTarget(self, action: #selector(onButLocationList), for: .touchUpInside)
            
            cellItem = cellUser
        }
        else {
            var isEmpty = true

            if let user = self.user, user.type == UserType.customer {
                if mnListType == ProfileViewController.LIST_TYPE_PAYMENT {
                    if let cards = user.stripeCards {
                        isEmpty = cards.isEmpty
                        
                        if !isEmpty {
                            // card cell
                            let cellCard = tableView.dequeueReusableCell(withIdentifier: CELLID_CARD) as? ProfileCardCell
                            cellCard?.fillContent(cards[indexPath.row])
                            
                            cellItem = cellCard
                        }
                    }
                }
                else {
                    if let addrs = user.addresses {
                        isEmpty = addrs.isEmpty

                        if !isEmpty {
                            // location cell
                            let cellLocation = tableView.dequeueReusableCell(withIdentifier: CELLID_LOCATION) as? ProfileLocationCell
                            cellLocation?.fillContent(addrs[indexPath.row])

                            cellItem = cellLocation
                        }
                    }
                }
            }
            
            if isEmpty {
                // empty notice
                let cellEmpty = tableView.dequeueReusableCell(withIdentifier: CELLID_EMPTY) as? ProfileEmptyCell
                cellEmpty?.fillContent(listType: mnListType)
                
                cellItem = cellEmpty
            }
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
        
        // showing in customer page only
        if self.user?.type == UserType.driver {
            return view
        }
        
        if section == 1 {
            let viewHeader = ProfileCardListHeader.getView(listType: mnListType) as! ProfileCardListHeader
            viewHeader.showView(true, animated: false)
            
//            if self.user!.isEqual(to: User.currentUser!) {
//                // add button action
//                viewHeader.mButAdd.addTarget(self, action: #selector(onButAddCard), for: .touchUpInside)
//            }
//            else {
                // hide add button
                viewHeader.mButAdd.isHidden = true
//            }
            
            view = viewHeader
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view: UIView?
        
        // showing in customer page only
        if self.user?.type == UserType.driver {
            return view
        }
        
        if section == 1 && mnListType == ProfileViewController.LIST_TYPE_LOCATION {
            let viewFooter = ProfileLocationListFooter.getView() as! ProfileLocationListFooter
            viewFooter.showView(true, animated: false)
            
            // can add address for his own profile only
            if self.user!.isEqual(to: User.currentUser!) {
                // add button action
                viewFooter.mButAdd.addTarget(self, action: #selector(onButAddLocation), for: .touchUpInside)
            }
            else {
                // hide add button
                viewFooter.mButAdd.isHidden = true
            }
            
            view = viewFooter
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // user cell is not editable
        if indexPath.section == 0 {
            return false
        }
        
        // working for customer case only
        if self.user?.type == UserType.driver {
            return false
        }
        
        // card list is not editable
        if mnListType == ProfileViewController.LIST_TYPE_PAYMENT {
            return false
        }
        
        if let user = self.user {
            // can add address for his own profile only
            if !user.isEqual(to: User.currentUser!) {
                return false
            }
                
            if let addrs = user.addresses {
                if !addrs.isEmpty {
                    return true
                }
            }
        }

        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // delete address
            self.alert(title: "Are you sure to delete this address?",
                       message: "",
                       okButton: "OK",
                       cancelButton: "Cancel",
                       okHandler: { (_) in
                        self.doDeleteAddress(indexPath.row)
            }, cancelHandler: nil)
        }
    }
}

extension ProfileViewController: STPAddCardViewControllerDelegate {
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        print("addCardViewControllerDidCancel")
        
        dismiss(animated: true)
    }

    func addCardViewController(_ addCardViewController: STPAddCardViewController,
                               didCreateToken token: STPToken,
                               completion: @escaping STPErrorBlock) {
        guard let card = token.card else {
            return
        }

        self.user?.addStripeCard(Card(withSTPCard: card))
        self.mTableView.reloadData()
        
        dismiss(animated: true)
    }
}

extension ProfileViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place location \(place.coordinate.latitude), \(place.coordinate.longitude)")
        
        if viewController == self.placePicker {
            // make new address
            let addrNew = Address()
            
            addrNew.latitude = place.coordinate.latitude
            addrNew.longitude = place.coordinate.longitude
            
            if let location = place.formattedAddress {
                addrNew.location = location
            }
            
            guard let user = self.user else {
                return
            }
            
            // restaurant from 2nd address
            if let addrs = user.addresses, !addrs.isEmpty {
                addrNew.type = AddressType.restaurant
            }
            
            // save to db
            addrNew.saveToDatabase(parentID: user.id)
            
            // add to list
            self.user?.addAddress(addrNew)
            self.mTableView.reloadData()
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
}
