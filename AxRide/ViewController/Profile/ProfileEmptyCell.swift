//
//  ProfileEmptyCell.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileEmptyCell: UITableViewCell {

    @IBOutlet weak var mLblNotice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillContent(user: User?, listType: Int) {
        // customer
        if user?.type == UserType.customer {
            if listType == ProfileViewController.LIST_TYPE_PAYMENT {
                mLblNotice.text = "No cards added yet"
            }
            else {
                mLblNotice.text = "No locations added yet"
            }
        }
        // driver
        else {
            if listType == ProfileViewController.LIST_TYPE_PAYMENT {
                mLblNotice.text = "No history yet"
            }
            else {
                mLblNotice.text = "No rates yet"
            }
        }
    }
}
