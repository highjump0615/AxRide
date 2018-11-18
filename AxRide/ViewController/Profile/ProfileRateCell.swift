//
//  ProfileRateCell.swift
//  AxRide
//
//  Created by Administrator on 11/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Cosmos

class ProfileRateCell: UITableViewCell {
    
    @IBOutlet weak var mButUser: UIButton!
    @IBOutlet weak var mViewStar: CosmosView!
    @IBOutlet weak var mLblUser: UILabel!
    @IBOutlet weak var mLblContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mButUser.makeRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillContent(_ data: Rate) {
        // user info
        if let user = data.user {
            if let photoUrl = user.photoUrl {
                mButUser.sd_setImage(with: URL(string: photoUrl),
                                     for: .normal,
                                     placeholderImage: UIImage(named: "UserDefault"),
                                     options: .progressiveDownload,
                                     completed: nil)
            }
            
            let time = Utils.stringElapsed(timestamp: data.createdAt)
            mLblUser.text = "by \(user.userFullName()) \(time)"
        }
        
        // rate
        mViewStar.rating = data.rating
        
        // content
        if data.text.isEmpty {
            mLblContent.text = " "
        }
        else {
            mLblContent.text = data.text
        }
        
    }

}
