//
//  ChatListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/19.
//

import Alamofire
import Firebase
import FirebaseStorageUI
import SVProgressHUD
import UIKit

class ChatListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private var chatListsData: [ChatList] = []

    private var documentIdArray: [String] = []

    var secondTabBarController: SecondTabBarController!

    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
            self.screenTransitionToLoginViewController()
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    private func screenTransitionToLoginViewController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        self.tableView.isEditing = false

        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem

        let editBarButtonBarItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.tappedEditBarButtonItem(_:)))
        self.secondTabBarController.navigationItem.rightBarButtonItems = [editBarButtonBarItem]

        guard Auth.auth().currentUser != nil else {
            self.secondTabBarController.navigationItem.title = "チャットリスト"
            self.chatListsData = []
            self.documentIdArray = []
            editBarButtonBarItem.isEnabled = false
            self.tableView.reloadData()
            return
        }
        self.secondTabBarController.navigationItem.title = "チャットリスト(0)"
        self.getChatListDocument()

        GetDocument.observeIfYouAreAboutToBeAddedAsFriend { result in
            switch result {
            case let .failure(error):
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                print("データの取得に失敗しました\(error.localizedDescription)")
            case let .success(queryDocumentSnapshot):
                if self.documentIdArray.contains(queryDocumentSnapshot.documentID) {
                    self.tableView.reloadData()
                    return
                }
                self.chatListsData.append(ChatList(queryDocumentSnapshot: queryDocumentSnapshot))
                self.tableView.reloadData()
            }
        }
        editBarButtonBarItem.isEnabled = true
    }

    @objc func tappedEditBarButtonItem(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }

    private func getChatListDocument() {
        let user = Auth.auth().currentUser!
        self.listener?.remove()
        self.chatListsData.removeAll()
        self.tableView.reloadData()

        GetDocument.getChatListDocument(user: user, listener: self.listener) { chatListData, documentIdArray in
            SVProgressHUD.dismiss()
            self.chatListsData = chatListData
            self.documentIdArray = documentIdArray
            self.setTitle(numberOfFriends: chatListData.count)
            self.tableView.reloadData()
        }
    }

    private func setTitle(numberOfFriends: Int) {
        let numberOfFriendsString = String(numberOfFriends)
        self.secondTabBarController.navigationItem.title = "チャットリスト(\(numberOfFriendsString))"
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return self.chatListsData.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListTableViewCell
        let chatListData = self.chatListsData[indexPath.row]

        cell.latestMessageLabel.text = chatListData.latestMessage
        cell.latestMessagedDate.text = chatListData.latestMessagedDate

        if let partnerImageUrl = chatListData.partnerProfileImageUrl {
            cell.profileImageView.sd_setImage(with: partnerImageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
        } else {
            cell.profileImageView.image = UIImage(systemName: "person")
        }

        let chatMembersNameFirstIsMyName: Bool = self.getMyName(chatListData: chatListData)
        switch chatMembersNameFirstIsMyName {
        case true:
            // my name
            cell.nameLabel.text = chatListData.chatMembersName?[1]
        case false:
            // partner name
            cell.nameLabel.text = chatListData.chatMembersName?.first
        }
        return cell
    }

    func getMyName(chatListData: ChatList) -> Bool {
        let user = Auth.auth().currentUser!
        var chatMembersFirstIsMyName: Bool
        if chatListData.chatMembersName?.first == user.displayName {
            chatMembersFirstIsMyName = true
        } else {
            chatMembersFirstIsMyName = false
        }
        return chatMembersFirstIsMyName
    }

    private func getMyUidAndPartnerUid(chatListData: ChatList) -> [String] {
        let user = Auth.auth().currentUser
        var chatMembersFirstisMyUid: Bool
        if chatListData.chatMembers?.first == user?.uid {
            chatMembersFirstisMyUid = true
        } else {
            chatMembersFirstisMyUid = false
        }
        var myUid = ""
        var partnerUid = ""
        switch chatMembersFirstisMyUid {
        case true:
            myUid = (chatListData.chatMembers?.first!)!
            partnerUid = chatListData.chatMembers![1]
        case false:
            myUid = chatListData.chatMembers![1]
            partnerUid = (chatListData.chatMembers?.first!)!
        }
        return [myUid, partnerUid]
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatListData = self.chatListsData[indexPath.row]
        self.performSegue(withIdentifier: "ToChatRoom", sender: chatListData)
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showUIAlertForDeleting(indexPath: indexPath)
        }
    }

    // when you delete a friend, they will also be deleted automatically
    func showUIAlertForDeleting(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除しますか？", message: "削除した場合、あなたと相手の全てのチャット履歴が削除されます", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { _ in
            DeleteData.deleteMessages(indexPath: indexPath, documentIdArray: self.documentIdArray) { error in
                if let error = error {
                    print("データの取得または、データの削除に失敗しました\(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "データの取得または、データの削除に失敗しました")
                    return
                }
                DeleteData.deleteDocumentInChatListsCollection(documentIdArray: self.documentIdArray, indexPath: indexPath) {
                    self.documentIdArray.remove(at: indexPath.row)
                    self.chatListsData.remove(at: indexPath.row)
                    self.setTitle(numberOfFriends: self.chatListsData.count)
                    self.tableView.reloadData()
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChatRoom" {
            let chatRoomViewController = segue.destination as! ChatRoomViewController
            chatRoomViewController.chatListData = sender as? ChatList
            chatRoomViewController.secondTabBarController = self.secondTabBarController
        }
    }
}

class ChatListTableViewCell: UITableViewCell {
    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var latestMessageLabel: UILabel!
    @IBOutlet var latestMessagedDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = 35
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.borderWidth = 2.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
