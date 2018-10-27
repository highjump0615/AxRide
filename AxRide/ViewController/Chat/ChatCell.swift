//
//  ChatFromCell.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var mImgViewUser: UIImageView?
    @IBOutlet weak var mLblMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mImgViewUser?.makeRound()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillContent(msg: Message) {
        if let user = msg.sender {
            // user photo
            if let photoUrl = user.photoUrl {
                mImgViewUser?.sd_setImage(with: URL(string: photoUrl),
                                          placeholderImage: UIImage(named: "UserDefault"),
                                          options: .progressiveDownload,
                                          completed: nil)
            }
        }
        
        // text
        mLblMsg.text = msg.text
    }
}
