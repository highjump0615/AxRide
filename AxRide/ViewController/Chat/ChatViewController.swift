//
//  ChatViewController.swift
//  AxRide
//
//  Created by Administrator on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: BaseViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var mTextMessage: UITextField!
    @IBOutlet weak var mViewInput: UIView!
    
    var messages: [Message] = []
    var userTo: User?
    
    // chat room between current and to user
//    var mChat: Chat?
//    var mChatId: String = ""
    
    var mKeyboardHeight: CGFloat = 0.0
    
    var mDbRef: DatabaseReference?
    
    private let CELLID_CHAT_TO = "ChatToCell"
    private let CELLID_CHAT_FROM = "ChatFromCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar(transparent: false)
        
        // title
        self.title = self.userTo?.userFullName()
        
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
        
        //
        // init data
        //
//        mChatId = Chat.makeIdWith2User(self.userTo!.id, User.currentUser!.id)
        
//        fetchChat()
        getMessages()
    }
    
    deinit {
        mDbRef?.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onButSend(_ sender: Any) {
        self.view.endEditing(true)
        
        // send
        let text = mTextMessage.text!
        if text.isEmpty {
            return
        }
        
        //
        // update chat info
        //
        let userCurrent = User.currentUser!
//        if mChat == nil {
//            mChat = Chat()
//        }
//        mChat?.senderId = userCurrent.id
//        mChat?.text = text
//
//        mChat?.saveToDatabaseManually(withID: mChatId, parentID: userCurrent.id)
//        mChat?.saveToDatabaseManually(withID: mChatId, parentID: self.userTo?.id)
        
        //
        // add new mesage
        //
        let msgNew = Message()
        msgNew.senderId = userCurrent.id
        msgNew.sender = userCurrent
        msgNew.text = text
        
        msgNew.saveToDatabase(parentID: userCurrent.id + "/" + self.userTo!.id)
        msgNew.saveToDatabase(parentID: self.userTo!.id + "/" + userCurrent.id)
        
        self.messages.append(msgNew)
        
        // clear textfield
        self.mTextMessage.text = ""
        
        // update table
        updateTable()
        
        // send notification to user
    }
    
    @objc func onButPhone() {
        // phone call to driver
        if Utils.isStringNullOrEmpty(text: self.userTo?.phone) {
            // no contact, error notice
            self.alertOk(title: "No contact info",
                         message: "User didn't register a phone number",
                         cancelButton: "OK",
                         cancelHandler: nil)
            return
        }
        
        guard let number = URL(string: "tel://" + (self.userTo?.phone)!) else { return }
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
    
//    func fetchChat() {
//        let userCurrent = User.currentUser!
//
//        if mChat != nil {
//            // already fetched, return
//            return
//        }
//
//        // fetch chat room
//        let db = FirebaseManager.ref()
//            .child(Chat.TABLE_NAME)
//            .child(userCurrent.id)
//            .child(self.userTo!.id)
//        db.observeSingleEvent(of: .value) { (snapshot) in
//            if !snapshot.exists() {
//                return
//            }
//
//            self.mChat = Chat(snapshot: snapshot)
//        }
//    }
    
    func getMessages() {
        let userCurrent = User.currentUser!
        
        self.messages.removeAll()
        
//        mDbRef = FirebaseManager.ref()
//            .child(Chat.TABLE_NAME)
//            .child(userCurrent.id)
//            .child(mChatId)
//            .child(Message.TABLE_NAME)
        mDbRef = FirebaseManager.ref()
            .child(Message.TABLE_NAME)
            .child(userCurrent.id)
            .child(self.userTo!.id)
        
        mDbRef?.observe(.childAdded, with: { (snapshot) in
            let msg = Message(snapshot: snapshot)
            msg.id = snapshot.key
            
            // set user
            msg.sender = msg.senderId == userCurrent.id ? userCurrent : self.userTo
            
            var isExist = false
            for aMsg in self.messages {
                if aMsg.isEqual(to: msg) {
                    isExist = true
                    break
                }
            }
            
            if !isExist {
                DispatchQueue.main.async {
                    self.messages.append(msg)
                    
                    self.updateTable()
                }
            }
        })
    }
    
    func updateTable(animated: Bool = false) {
        if animated {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            mTableView.insertRows(at: [indexPath], with: .automatic)
        }
        else {
            mTableView.reloadData()
        }
        
        self.tableViewScrollToBottom(animated: false)
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
        let userCurrent = User.currentUser!
        let msg = messages[indexPath.row]
        
        var strCellId = CELLID_CHAT_FROM
        if msg.senderId == userCurrent.id {
            strCellId = CELLID_CHAT_TO
        }
        
        let cellItem = tableView.dequeueReusableCell(withIdentifier: strCellId) as! ChatCell
        cellItem.backgroundColor = .clear
        cellItem.fillContent(msg: msg)

        // user tap event
//        cellItem.mButUser.tag = indexPath.row
//        cellItem.mButUser.addTarget(self, action: #selector(onButUser), for: .touchUpInside)
        
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

