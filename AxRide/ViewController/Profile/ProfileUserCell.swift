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
