//
//  OthersProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Firebase
import Parchment
import SVProgressHUD
import UIKit

class OthersProfileViewController: UIViewController {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var workLabel: UILabel!
    @IBOutlet var pagingView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var likeNumberLabel: UILabel!
    @IBOutlet var postNumberLabel: UILabel!

    var postData: PostData!
    var seocndPostData: SecondPostData!
    var profileData: [String: Any] = [:]
    var postData2: PostData!
    var documentId: String?

    var secondTabBarController: SecondTabBarController!
    var commentSectionViewController: CommentSectionViewController!
    var pagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "プロフィール"

        let othersIntroductionViewController = storyboard?.instantiateViewController(identifier: "OthersIntroduction") as! OthersIntroductionViewController
        othersIntroductionViewController.postData = self.postData

        let navigationController = storyboard?.instantiateViewController(withIdentifier: "OthersNC") as! UINavigationController
        let othersPostsHistoryViewController = navigationController.viewControllers[0] as! OthersPostsHistoryViewController
        othersPostsHistoryViewController.postData = self.postData
        othersPostsHistoryViewController.delegate = self

        let othersPostedCommentsHistoryViewController = storyboard?.instantiateViewController(withIdentifier: "OthersPostedCommentsHistory") as! OthersPostedCommentsHistoryViewController
        othersPostedCommentsHistoryViewController.postData = self.postData

//        let navigationController2 = storyboard?.instantiateViewController(withIdentifier: "OthersNC2") as! UINavigationController
//        let othersBookMarkViewController = navigationController2.viewControllers[0] as! OthersBookMarkViewController
//        othersBookMarkViewController.postData = self.postData
//        プロフィール画像設定
        self.setImageFromStorage()

        othersIntroductionViewController.title = "自己紹介"
        navigationController.title = "投稿履歴"
        othersPostedCommentsHistoryViewController.title = "コメント履歴"
//        navigationController2.title = "ブックマーク"

//        pagingViewControllerのインスタンス生成
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

        //        丸いimageView
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        //        画像にデフォルト設定
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

    func getProfileDataDocument() {
        print("postDataのuid確認\(self.postData.uid!)")
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
        // Do any additional setup after loading the view.
    }

    func setProfileDataOnLabels(profileData _: [String: Any]) {
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

    func setImageFromStorage() {
        //            storageから画像を取り出して、imageViewに設置
        let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(self.postData.uid!)" + ".jpg")

        self.profileImageView.sd_setImage(with: imageRef)
        print("画像取り出せた？\(imageRef)")
    }

//    プロフィールが自分の場合、友達追加ボタンのisenabledをfalseにする
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

//    友達追加ボタン押下時に、既に友達に追加されているかどうかを判定する
    func seeIfThePartnerIsAlreadyAdded(user: User, completion: @escaping () -> Void) {
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
                    SVProgressHUD.dismiss(withDelay: 2.0)
                    return
                }
//                まだ友達に追加されていない場合
                completion()
            }
        }
    }

    func showAlert() {
        let user = Auth.auth().currentUser!
        let alert = UIAlertController(title: "友達に追加しますか？", message: "'\(self.postData.userName!)'がチャットリストに追加されます", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "追加", style: .default, handler: { _ in
            SVProgressHUD.show()
            let chatDic = [
                "createdAt": FieldValue.serverTimestamp(),
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
