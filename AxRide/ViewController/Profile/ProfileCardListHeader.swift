//
//  ProfileCardListHeader.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ProfileCardListHeader: BaseCustomView {
    
    @IBOutlet weak var mLblTitle: UILabel!
    @IBOutlet weak var mButAdd: UIButton!
    
    static func getView(listType: Int) -> UIView {
        let view = super.getView(nibName: "ProfileCardListHeader") as! ProfileCardListHeader
        view.fillContent(listType: listType)
        
        return view
    }
    
    func fillContent(listType: Int) {
        if listType == ProfileViewController.LIST_TYPE_LOCATION {
            mLblTitle.text = "Locations"
            mButAdd.isHidden = true
        }
        else {
            mLblTitle.text = "Cards"
        }
    }
    
    

}
