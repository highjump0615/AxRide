//
//  RideModeView.swift
//  AxRide
//
//  Created by Administrator on 10/7/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

protocol RideModeDelegate: Any {
    func onChangeMode(_ mode: Int)
}

class RideModeView: BaseCustomView {
    
    @IBOutlet weak var mImgViewRideNormal: UIImageView!
    @IBOutlet weak var mImgViewRideSuv: UIImageView!
    @IBOutlet weak var mImgViewRideShare: UIImageView!
    
    @IBOutlet weak var mButNormal: UIButton!
    @IBOutlet weak var mButSuv: UIButton!
    @IBOutlet weak var mButShare: UIButton!
    
    var delegate: RideModeDelegate?
    
    static func getView() -> UIView {
        return super.getView(nibName: "RideModeView")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // init images
        mImgViewRideNormal.image = mImgViewRideNormal.image!.withRenderingMode(.alwaysTemplate)
        mImgViewRideSuv.image = mImgViewRideSuv.image!.withRenderingMode(.alwaysTemplate)
        mImgViewRideShare.image = mImgViewRideShare.image!.withRenderingMode(.alwaysTemplate)
        
        clearModeColor()
    }
    
    func enableSwitch(_ enable: Bool) {
        mButNormal.makeEnable(enable: enable)
        mButSuv.makeEnable(enable: enable)
        mButShare.makeEnable(enable: enable)
    }
    
    func clearModeColor() {
        mImgViewRideNormal.tintColor = Constants.gColorGray
        mImgViewRideSuv.tintColor = Constants.gColorGray
        mImgViewRideShare.tintColor = Constants.gColorGray
    }
    
    /// update switch based on current mode
    ///
    /// - Parameter rideMode: <#rideMode description#>
    func updateRideView(_ rideMode: Int) {
        clearModeColor()
        
        switch rideMode {
        case Order.RIDE_MODE_NORMAL:
            mImgViewRideNormal.tintColor = Constants.gColorPurple
            
        case Order.RIDE_MODE_SUV:
            mImgViewRideSuv.tintColor = Constants.gColorPurple
            
        case Order.RIDE_MODE_SHARE:
            mImgViewRideShare.tintColor = Constants.gColorPurple
            
        default:
            break
        }
    }
    
    @IBAction func onButRideNormal(_ sender: Any) {
        let mode = Order.RIDE_MODE_NORMAL

        // update UI
        updateRideView(mode)
        delegate?.onChangeMode(mode)
    }
    
    @IBAction func onButRideSuv(_ sender: Any) {
        let mode = Order.RIDE_MODE_SUV
        
        // update UI
        updateRideView(mode)
        delegate?.onChangeMode(mode)
    }
    
    @IBAction func onButRideShare(_ sender: Any) {
        let mode = Order.RIDE_MODE_SHARE
        
        // update UI
        updateRideView(mode)
        delegate?.onChangeMode(mode)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
