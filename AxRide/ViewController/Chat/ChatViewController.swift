//
//  ChatViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mTextMessage: UITextField!
    @IBOutlet weak var mViewInput: UIView!
    
    var messages: [Message] = []
    
    var mKeyboardHeight: CGFloat = 0.0
    
    private let CELLID_CHAT_TO = "ChatToCell"
    private let CELLID_CHAT_FROM = "ChatFromCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar(transparent: false)
        self.title = "Wendell"
        
        mViewInput.addTopBorderWithColor(color: Constants.gColorGray, width: 0.5)

        // right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ButChatPhone"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onButPhone))
        
        // init tableview
        mTableView.register(UINib(nibName: "ChatItemViewTo", bundle: nil), forCellReuseIdentifier: CELLID_CHAT_TO)
        mTableView.register(UINib(nibName: "ChatItemViewFrom", bundle: nil), forCellReuseIdentifier: CELLID_CHAT_FROM)
        
        // keyboard avoiding
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        // init data
        messages.append(Message())
        messages.append(Message())
        messages.append(Message())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButSend(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func onButPhone() {
        // phone call to driver
        
        guard let number = URL(string: "tel://" + "1393847598") else { return }
        UIApplication.shared.open(number)
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            if self.mTableView.contentSize.height > self.mTableView.frame.size.height {
                let bottomOffset = CGPoint(x: 0,
                                           y: self.mTableView.contentSize.height - self.mTableView.frame.size.height)
                self.mTableView.setContentOffset(bottomOffset, animated: animated)
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification?) -> CGFloat {
        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return 0
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        return keyboardHeight
    }

    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        if mKeyboardHeight > 0 {
            // already showing keyboard, return
            return
        }
        
        var frmView = self.view.frame
        mKeyboardHeight = getKeyboardHeight(notification: notification)
        frmView.size = CGSize(width: frmView.width, height: frmView.height - mKeyboardHeight)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.view.frame = frmView
        }) { (finished) in
            self.tableViewScrollToBottom(animated: false)
        }
    }
    
    func keyboardWillDisappear() {
        var frmView = self.view.frame
        frmView.size = CGSize(width: frmView.width, height: frmView.height + mKeyboardHeight)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.view.frame = frmView
        })
        
        mKeyboardHeight = 0
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

extension ChatViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        
        var strCellId = CELLID_CHAT_FROM
        if indexPath.row == 1 {
            strCellId = CELLID_CHAT_TO
        }
        
        let cellItem = tableView.dequeueReusableCell(withIdentifier: strCellId) as! ChatCell
        cellItem.backgroundColor = .clear
        
        return cellItem
    }
    
}

extension ChatViewController : UITableViewDelegate {
}

extension ChatViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onButSend(mTextMessage)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        keyboardWillDisappear()
        
        return true
    }
}

