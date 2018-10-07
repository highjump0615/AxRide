//
//  UserWaitPopup.swift
//  AxRide
//
//  Created by Administrator on 8/12/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol PopupDelegate: Any {
    func onClosePopup(_ sender: Any?)
}

class UserWaitPopup: BaseCustomView {

    @IBOutlet weak var mProgressTimer: UICircularProgressRing!
    @IBOutlet weak var mLblTimer: UILabel!
    
    var timer: Timer?
    var nTime = 0
    
    var delegate: PopupDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static func getView() -> UIView {
        return super.getView(nibName: "UserWaitPopup")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onButCancel(_ sender: Any?) {
        stopTimer()
        self.showView(false, animated: true)
        
        delegate?.onClosePopup(sender)
    }
    
    func updateTime(_ value: Int) {
        nTime = value
        
        let strTime = String(format: "%02d:%02d", nTime / 60, nTime % 60)
        mLblTimer.text = strTime

        mProgressTimer.value = UICircularProgressRing.ProgressValue(value)
    }

    func startTimer() {
        // init progress
        updateTime(0)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.updateTime(self.nTime + 1)
            
            if self.nTime >= 120 {
                self.onButCancel(nil)
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}
