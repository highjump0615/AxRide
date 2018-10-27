//
//  ProfileUserCell.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileUserCell: UITableViewCell {
    
    @IBOutlet weak var mImgViewUser: UIImageView!
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mLblAddress: UILabel!
    @IBOutlet weak var mButPayment: UIButton!
    @IBOutlet weak var mButLocation: UIButton!
    
    @IBOutlet weak var mViewLocation: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mImgViewUser.makeRound()
        
        // init button colors
        initButtonColors()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initButtonColors() {
        mButPayment.setBackgroundColor(Constants.gColorSemiPurple, for: .normal)
        mButLocation.setBackgroundColor(Constants.gColorSemiPurple, for: .normal)
    }
    
    func fillContent(user: User?) {
        // fill info
        guard let u = user else {
            return
        }
        
        if let photoUrl = u.photoUrl {
            mImgViewUser.sd_setImage(with: URL(string: photoUrl),
                                     placeholderImage: UIImage(named: "UserDefault"),
                                     options: .progressiveDownload,
                                     completed: nil)
        }
        
        mLblName.text = u.userFullName()
        
        if let address = u.location {
            mViewLocation.isHidden = false
            mLblAddress.text = address
        }
        else {
            mViewLocation.isHidden = true
        }
        
        // update button labels
        if u.type == UserType.customer {
            mButPayment.setTitle("Payment Accounts", for: .normal)
            mButLocation.setTitle("Saved Locations", for: .normal)
        }
        else if u.type == UserType.driver {
            mButPayment.setTitle("Payment History", for: .normal)
            mButLocation.setTitle("Rating and Reviews", for: .normal)
        }
    }
    
    func updateListType(type: Int) {
        initButtonColors()
        
        if type == ProfileViewController.LIST_TYPE_PAYMENT {
            mButPayment.setBackgroundColor(Constants.gColorPurple, for: .normal)
        }
        else {
            mButLocation.setBackgroundColor(Constants.gColorPurple, for: .normal)
        }
    }

}
