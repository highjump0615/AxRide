//
//  OnboardViewController.swift
//  AxRide
//
//  Created by Administrator on 7/15/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {
    
    static let KEY_TUTORIAL = "tutorial"
    
    // view 1
    @IBOutlet weak var mLblTitle1: UILabel!
    
    // view 2
    @IBOutlet weak var mLblRight: UILabel!
    @IBOutlet weak var mLblWelcome: UILabel!
    @IBOutlet weak var mLblAppName: UILabel!
    @IBOutlet weak var mLblDesc: UILabel!
    
    @IBOutlet weak var mButNext: UIButton!
    @IBOutlet weak var mPageControl: UIPageControl!
    @IBOutlet weak var mScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar(show: false)

        // Do any additional setup after loading the view.
        mButNext.makeRound(r: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //
        // title labels
        //
        let width = self.view.bounds.width
        let widthDesign: CGFloat = 375
        
        // view 1
        mLblTitle1.font = ARTextHelper.exoBold(size: width / widthDesign * 30)
        
        // view 2
        mLblRight.font = ARTextHelper.exoBold(size: width / widthDesign * 18)
        mLblWelcome.font = ARTextHelper.exoBold(size: width / widthDesign * 20)
        mLblAppName.font = ARTextHelper.exoBold(size: width / widthDesign * 50)
        mLblDesc.font = ARTextHelper.exoBold(size: width / widthDesign * 22)
    }
    
    @IBAction func onButSkip(_ sender: Any) {
    }
    
    @IBAction func onButNext(_ sender: Any) {
        if mPageControl.currentPage == 0 {
            // go to next view pager
            var pt = mScrollView.contentOffset
            pt.x += mScrollView.frame.size.width
            
            mScrollView.setContentOffset(pt, animated: true)
            
            // update page control
            mPageControl.currentPage = 1
        }
        else {
            UserDefaults.standard.set(true, forKey: OnboardViewController.KEY_TUTORIAL)
            
            // go to next page
            let signinVC = SigninViewController(nibName: "SigninViewController", bundle: nil)
            self.navigationController?.pushViewController(signinVC, animated: true)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OnboardViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = mScrollView.frame.size.width
        let nPage = (Int)(mScrollView.contentOffset.x / pageWidth)
        
        mPageControl.currentPage = nPage
        
        mButNext.setTitle(nPage == 1 ? "Done" : "Next", for: .normal)
    }
}
