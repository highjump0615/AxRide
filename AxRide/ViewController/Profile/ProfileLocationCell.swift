//
//  ProfileLocationCell.swift
//  AxRide
//
//  Created by Administrator on 11/17/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileLocationCell: UITableViewCell {
    
    @IBOutlet weak var mImgviewType: UIImageView!
    @IBOutlet weak var mLblType: UILabel!
    @IBOutlet weak var mLblAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillContent(_ data: Address) {
        // image
        if data.type == AddressType.home {
            mImgviewType.image = UIImage(named: "ProfileLocationHome")
        }
        else {
            mImgviewType.image = UIImage(named: "ProfileLocationRestaurant")
        }
        
        // type
        mLblType.text = data.typeString()
        
        // address
        mLblAddress.text = data.location
    }

}
