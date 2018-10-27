//
//  ProfileDriverUserCell.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileDriverUserCell: UITableViewCell {
    
    @IBOutlet weak var mImgViewUser: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        mImgViewUser.makeRound()
    }
}
