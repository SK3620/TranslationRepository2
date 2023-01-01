//
//  OthersProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Firebase
import FirebaseStorageUI
import Parchment
import SVProgressHUD
import UIKit

// function described here is almost the same as the one in ProfileViewController
class OthersProfileViewController: UIViewController {
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var genderLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    @IBOutlet private var workLabel: UILabel!
    @IBOutlet private var pagingView: UIView!
    @IBOutlet private var profileImageView: UIImageView!

    @IBOutlet var likeNumberLabel: UILabel!
    @IBOutlet var postNumberLabel: UILabel!

    var postData: PostData!
    var postData2: PostData!

    private var profileData: [String: Any] = [:]

    var documentId: String?

    var secondTabBarController: SecondTabBarController!
    var commentSectionViewController: CommentSectionViewController!
    var pagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "プロフィール"

        // プロフィール画像設定
        self.setImageFromStorage()

        self.settingsForPagingViewController()

        self.settingsForProfileImageView()
    }

    private func settingsForPagingViewController() {
        let othersIntroductionViewController = storyboard?.instantiateViewController(identifier: "OthersIntroduction") as! OthersIntroductionViewController
        othersIntroductionViewController.postData = self.postData

        let navigationController = storyboard?.instantiateViewController(withIdentifier: "OthersNC") as! UINavigationController
        let othersPostsHistoryViewController = navigationController.viewControllers[0] as! OthersPostsHistoryViewController
        othersPostsHistoryViewController.postData = self.postData
        othersPostsHistoryViewController.delegate = self

        let othersPostedCommentsHistoryViewController = storyboard?.instantiateViewController(withIdentifier: "OthersPostedCommentsHistory") as! OthersPostedCommentsHistoryViewController
        othersPostedCommentsHistoryViewController.postData = self.postData

        othersIntroductionViewController.title = "自己紹介"
        navigationController.title = "投稿履歴"
        othersPostedCommentsHistoryViewController.title = "コメント履歴"

        let pagingViewController = PagingViewController(viewControllers: [othersIntroductionViewController, navigationController, othersPostedCommentsHistoryViewController])

//        Adds the specified view controller as a child of the current view controller.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
//        Called after the view controller is added or removed from a container view controller.
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.leadingAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingViewController.view.topAnchor.constraint(equalTo: self.pagingView.safeAreaLayoutGuide.topAnchor).isActive = true
        pagingViewController.selectedTextColor = .black
        pagingViewController.textColor = .systemGray4
        pagingViewController.indicatorColor = .systemBlue
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 50)
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.select(index: 1)

        othersIntroductionViewController.secondPagingViewController = pagingViewController
        self.pagingViewController = pagingViewController
    }

    private func settingsForProfileImageView() {
        //        circle imageView
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        //        default settings for the image
        self.profileImageView.image = UIImage(systemName: "person")
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.borderWidth = 2.5
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.pagingViewController.select(index: 0)

        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let addFriendBarButtonItem = UIBarButtonItem(title: "友達追加", style: .plain, target: self, action: #selector(self.tappedAddFriendBarButtonItem))
        self.navigationItem.rightBarButtonItem = addFriendBarButtonItem
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.secondTabBarController.tabBar.isHidden = true

        self.makeAddFriendBarButtonItemEnabledFalse(addFriendBarButtonItem: addFriendBarButtonItem)
        self.getProfileDataDocument()
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        if let postData2 = self.postData2 {
            self.commentSectionViewController.postData = postData2
        }
    }

    private func getProfileDataDocument() {
        Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(self.postData.uid!)'sProfileDocument").getDocument(completion: { queryDocument, error in
            if let error = error {
                print("ドキュメント取得失敗\(error)")
            }
            if let queryDocument = queryDocument?.data() {
                print("取得成功\(queryDocument)")
                self.profileData = queryDocument
            }
            self.setProfileDataOnLabels(profileData: self.profileData)
        })
    }

    private func setProfileDataOnLabels(profileData _: [String: Any]) {
        self.userNameLabel.text = self.profileData["userName"] as? String
        if let genderText = self.profileData["gender"] as? String {
            self.genderLabel.text = genderText
        } else {
            self.genderLabel.text = "ー"
        }

        if let ageText = self.profileData["age"] as? String {
            self.ageLabel.text = ageText
        } else {
            self.ageLabel.text = "ー"
        }

        if let workText = self.profileData["work"] as? String {
            self.workLabel.text = workText
        } else {
            self.workLabel.text = "ー"
        }
    }

    private func setImageFromStorage() {
        let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(self.postData.uid!)" + ".jpg")
        imageRef.downloadURL { url, error in
            if let error = error {
                print("URLの取得失敗\(error)")
            }
            if let url = url {
                print("URLの取得成功: \(url)")
                self.profileImageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
            }
        }
    }

    // the profile is yours, disable the button to add a friend
    func makeAddFriendBarButtonItemEnabledFalse(addFriendBarButtonItem: UIBarButtonItem) {
        if let user = Auth.auth().currentUser {
            if user.uid == self.postData.uid {
                print("友達追加ボタンのiseabledをfalseにします")
                addFriendBarButtonItem.isEnabled = false
            } else {
                addFriendBarButtonItem.isEnabled = true
                print("友達追加ボタンのisEnabledをtrueにします")
            }
        }
    }

    @objc func tappedAddFriendBarButtonItem() {
        guard let user = Auth.auth().currentUser else {
            return
        }
//        completionで処理
        self.seeIfThePartnerIsAlreadyAdded(user: user) {
            self.showAlert()
        }
    }

    // Determine if a friend has already been added when the Add Friend button is pressed.
    private func seeIfThePartnerIsAlreadyAdded(user: User, completion: @escaping () -> Void) {
        let chatRef = Firestore.firestore().collection("chatLists").whereField("members", arrayContainsAny: [user.uid, self.postData.uid!])
        chatRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("既に友達追加されているかどうか判定するためのメソッド内で、ドキュメントの取得に失敗しました ：エラー内容\(error)")
            }
            if let querySnapshot = querySnapshot {
                print("既に友達追加されているかどうかを判定するためのメソッドで、ドキュメントの取得に成功しました。")
                let isAlreadyAdded: Bool = querySnapshot.documents.isEmpty
                guard isAlreadyAdded else {
//                    すでに追加されているため、returnする
                    SVProgressHUD.showError(withStatus: "'\(self.postData.userName!)'はすでに友達に追加されています")
                    SVProgressHUD.dismiss(withDelay: 3.0)
                    return
                }
                // If you have not yet been added as a friend
                completion()
            }
        }
    }

    private func showAlert() {
        let user = Auth.auth().currentUser!
        let alert = UIAlertController(title: "友達に追加しますか？", message: "'\(self.postData.userName!)'がチャットリストに追加されます", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "追加", style: .default, handler: { _ in
            SVProgressHUD.show()
            let chatDic = [
                "latestSentDate": FieldValue.serverTimestamp(),
                "latestMessage": "",
                "members": [user.uid, self.postData.uid],
                "membersName": [user.displayName, self.postData.userName],
                "partnerUid": self.postData.uid!,
            ] as [String: Any]
            Firestore.firestore().collection("chatLists").addDocument(data: chatDic) { error in
                if let error = error {
                    print("ChatRoomsの作成、追加に失敗しました\(error)")
                    SVProgressHUD.dismiss()
                } else {
                    print("ChatRoomsの作成、追加に成功しました")
                    SVProgressHUD.showSuccess(withStatus: "'\(self.postData.userName!)'をチャットリストに追加しました")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension OthersProfileViewController: setLikeAndPostNumberLabelForOthersDelegate {
    func setLikeAndPostNumberLabelForOthers(likeNumber: Int, postNumber: Int) {
        self.likeNumberLabel.text = "いいね \(String(likeNumber))"
        self.postNumberLabel.text = "投稿 \(String(postNumber))"
    }
}
