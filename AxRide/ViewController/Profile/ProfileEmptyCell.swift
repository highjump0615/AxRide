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

    func fillContent(listType: Int) {
        if listType == ProfileViewController.LIST_TYPE_PAYMENT {
            mLblNotice.text = "No cards added yet"
        }
        else {
            mLblNotice.text = "No locations added yet"
        }
        
    }
}
