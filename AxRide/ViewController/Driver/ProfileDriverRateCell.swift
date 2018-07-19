//
//  ProfileDriverRateCell.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileDriverRateCell: UITableViewCell {
    
    @IBOutlet weak var mButUser: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mButUser.makeRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
