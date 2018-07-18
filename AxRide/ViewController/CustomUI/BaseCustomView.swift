//
//  BaseCustomView.swift
//  AxRide
//
//  Created by Administrator on 7/18/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import UIKit

class BaseCustomView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    static func getView(nibName: String) -> UIView {
        let nib = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        let view = nib?[0] as? UIView
        
        return view!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.alpha = 0
    }
    
    func showView(bShow: Bool, animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.isHidden = false
                            self.alpha = bShow ? 1 : 0
            }) { (finished) in
                self.isHidden = !bShow
            }
        }
        else {
            self.alpha = bShow ? 1 : 0
            self.isHidden = !bShow
        }
    }
}
