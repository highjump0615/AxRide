//
//  ProfileCardCell.swift
//  AxRide
//
//  Created by Administrator on 11/16/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Stripe

class ProfileCardCell: UITableViewCell {
    
    @IBOutlet weak var imgviewCard: UIImageView!
    @IBOutlet weak var lblCardNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillContent(_ data: Card) {
        // image
        self.imgviewCard.image = STPImageLibrary.brandImage(for: data.brand)
        
        // card no
        self.lblCardNo.text = "XXXX-XXXX-XXXX-\(data.last4)"
    }

}
