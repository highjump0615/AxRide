//
//  ProfileOrderCell.swift
//  AxRide
//
//  Created by Administrator on 11/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileOrderCell: UITableViewCell {
    
    @IBOutlet weak var mButUser: UIButton!
    @IBOutlet weak var mLblName: UILabel!
    @IBOutlet weak var mLblFee: UILabel!
    @IBOutlet weak var mLblTime: UILabel!
    @IBOutlet weak var mLblFrom: UILabel!
    @IBOutlet weak var mLblTo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mButUser.makeRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillContent(_ data: Order) {
        // user info
        if let user = data.customer {
            if let photoUrl = user.photoUrl {
                mButUser.sd_setImage(with: URL(string: photoUrl),
                                     for: .normal,
                                     placeholderImage: UIImage(named: "UserDefault"),
                                     options: .progressiveDownload,
                                     completed: nil)
            }
            
            mLblName.text = user.userFullName()
        }
        
        // fee
        mLblFee.text = "$\(data.fee.format(f: ".2"))"
        
        // time
        mLblTime.text = Utils.stringElapsed(timestamp: data.createdAt)
        
        // from & to
        mLblFrom.text = data.fromAddr
        mLblTo.text = data.toAddr
    }

}
