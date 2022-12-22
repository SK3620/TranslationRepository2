//
//  ChatListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/19.
//

import Alamofire
import Firebase
import SVProgressHUD
import UIKit

class ChatListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var chatListsData: [ChatList] = []
    var documentIdArray: [String] = []
    var secondTabBarController: SecondTabBarController!
    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

//        self.fetchChatListsInfoFromFirestore()
//        self.observeIfYouAreAboutToBeAddedAsFriend()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.secondTabBarController.navigationItem.rightBarButtonItems = []

        self.fetchChatListsInfoFromFirestore()
        self.observeIfYouAreAboutToBeAddedAsFriend()
    }

    func fetchChatListsInfoFromFirestore() {
        self.listener?.remove()
        self.chatListsData.removeAll()
        self.tableView.reloadData()

        self.listener = Firestore.firestore().collection("chatLists").order(by: "createdAt", descending: true).addSnapshotListener { snapshots, error in
            if let error = error {
                print("ChatLists情報の取得に失敗しました。\(error)")
                return
            }
            print("ChatListsの情報の取得に成功しました")
            if let snapshots = snapshots {
                if snapshots.isEmpty {
                    print("ChatListsのsnapshotsは空でした")
                    self.setTitle(numberOfFriends: self.chatListsData.count)
                }
                snapshots.documents.forEach { queryDocumentSnapshot in
                    self.chatListsData.append(ChatList(queryDocumentSnapshot: queryDocumentSnapshot))
                    self.documentIdArray.append(ChatList(queryDocumentSnapshot: queryDocumentSnapshot).documentId!)
                    self.setTitle(numberOfFriends: self.chatListsData.count)
                    self.tableView.reloadData()
                }
            }
        }

//        snapshot.documentChanges.forEach{ diff in
//                   if (diff.type == .added){
//                       print("New Vegetables: \(diff.document.data())")
//                   }
//                   if (diff.type == .modified){
//                       print("Modified Vegetables: \(diff.document.data())")
//                   }
//                   if (diff.type == .removed){
//                       print("Removed Vegetables: \(diff.document.data())")
//                   }
//               }
    }

//    相手から友達追加された時の処理
    func observeIfYouAreAboutToBeAddedAsFriend() {
        if let user = Auth.auth().currentUser {
            let chatRef = Firestore.firestore().collection("chatLists").whereField("partnerUid", isEqualTo: user.uid)
            chatRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("友達追加した時の処理にて、getDocumenメソッドが失敗しました エラー内容：\(error)")
                }
                if let querySnapshot = querySnapshot {
                    print("友達追加した時の処理にて、getDocumentメソッドが成功しました")
                    if querySnapshot.isEmpty {
                        print("友達追加時の処理にて、getDocumentメソッドで取得したquerySnapshotは空でしたので、returnを実行します")
                        return
                    }
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        if self.documentIdArray.contains(queryDocumentSnapshot.documentID) {
                            self.tableView.reloadData()
                            return
                        }
                        self.chatListsData.append(ChatList(queryDocumentSnapshot: queryDocumentSnapshot))
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    func setTitle(numberOfFriends: Int) {
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
//        プロフィール画像はとりあえずpersonで。
        cell.profileImageView.image = UIImage(systemName: "person")
        cell.latestMessageLabel.text = chatListData.latestMessage
        cell.latestMessagedDate.text = chatListData.latestMessagedDate

        let chatMembersNameFirstIsMyName: Bool = self.getMyName(chatListData: chatListData)
        switch chatMembersNameFirstIsMyName {
        case true:
            cell.nameLabel.text = chatListData.chatMembersName?[1]
        case false:
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

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatListData = self.chatListsData[indexPath.row]
        self.performSegue(withIdentifier: "ToChatRoom", sender: chatListData)
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
