//
//  ProfileLocationListFooter.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileLocationListFooter: BaseCustomView {
    
    @IBOutlet weak var mButAdd: UIButton!
    
    static func getView() -> UIView {
        return super.getView(nibName: "ProfileLocationListFooter")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round corner
        mButAdd.makeRound(r: 12.0)
    }
    
}
