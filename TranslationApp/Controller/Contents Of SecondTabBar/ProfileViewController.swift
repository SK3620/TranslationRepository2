//
//  ProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import CLImageEditor
import Firebase
import FirebaseStorageUI
import Parchment
import SVProgressHUD
import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var pasingView: UIView!

    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var genderLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    @IBOutlet private var workLabel: UILabel!

    @IBOutlet private var changePhotoButton: UIButton!
    @IBOutlet private var label1: UILabel!

    @IBOutlet var likeNumberLabel: UILabel!
    @IBOutlet var postNumberLabel: UILabel!

    // image for storageReference
    var image: UIImage!

    var tabBarController1: TabBarController?

    var secondTabBarController: SecondTabBarController!

    private var rightBarButtonItem: UIBarButtonItem!
    private var rightEdgeBarButtonItem: UIBarButtonItem!

    var profileData: [String: Any] = [:]

    var pagingViewController: PagingViewController!

    var postsHistoryViewController: PostsHistoryViewController?
    var postedCommentsHistoryViewController: PostedCommentsHistoryViewController?
    var bookMarkViewController: BookMarkViewController?
    var bookMarkCommentsSectionViewController: BookMarkCommentsSectionViewController?
    var commentsHistoryViewController: CommentsHistoryViewController?

    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.configureMenuButton()

        if Auth.auth().currentUser == nil {
            self.screenTransitionToLoginViewController()
        }

        self.settingsForPagingViewController()

        //       circle imageView
        self.imageView.layer.cornerRadius = self.imageView.frame.height / 2
        //       default settings for
        self.imageView.image = UIImage(systemName: "person")
        self.imageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView.layer.borderWidth = 2.5
    }

    private func screenTransitionToLoginViewController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

    private func settingsForPagingViewController() {
        let introductionViewController = storyboard?.instantiateViewController(identifier: "introduction") as! IntroductionViewController
        introductionViewController.secondTabBarController = self.secondTabBarController

        let navigationController = storyboard?.instantiateViewController(withIdentifier: "NC") as! UINavigationController
        let postsHistoryViewController = navigationController.viewControllers[0] as! PostsHistoryViewController
        postsHistoryViewController.delegate = self
        postsHistoryViewController.profileViewController = self

        let postedCommentsHistoryViewController = storyboard?.instantiateViewController(withIdentifier: "postedCommentsHistory") as! PostedCommentsHistoryViewController
        postedCommentsHistoryViewController.profileViewController = self

        let navigationController2 = storyboard?.instantiateViewController(withIdentifier: "NC2") as! UINavigationController
        let bookMarkViewController = navigationController2.viewControllers[0] as! BookMarkViewController
        bookMarkViewController.profileViewController = self

        introductionViewController.title = "自己紹介"
        navigationController.title = "投稿履歴"
        postedCommentsHistoryViewController.title = "コメント履歴"
        navigationController2.title = "ブックマーク"

//       configure pagingViewController instance
        let pagingViewController = PagingViewController(viewControllers: [introductionViewController, navigationController, postedCommentsHistoryViewController, navigationController2])

//        Adds the specified view controller as a child of the current view controller.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
//        Called after the view controller is added or removed from a container view controller.
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.leadingAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingViewController.view.topAnchor.constraint(equalTo: self.pasingView.safeAreaLayoutGuide.topAnchor).isActive = true
        pagingViewController.selectedTextColor = .black
        pagingViewController.textColor = .systemGray4
        pagingViewController.indicatorColor = .systemBlue
        pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 50)
        pagingViewController.menuItemLabelSpacing = 0
        pagingViewController.select(index: 1)
        self.pagingViewController = pagingViewController
        introductionViewController.pagingViewController = pagingViewController

        self.navigationController?.navigationBar.backgroundColor = .systemGray4
    }

    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToEditProfile", sender: nil)
    }

    @objc func tappedRightEdgeBarButtonItem(_: UIBarButtonItem) {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.setRightBarButtonItem()

        if Auth.auth().currentUser == nil {
            self.settingsForLabelsAndButtons()
            return
        }

        SVProgressHUD.show(withStatus: "データ取得中...")
        if Auth.auth().currentUser != nil {
            self.changePhotoButton.isEnabled = true

            self.label1.text = ""

            if let user = Auth.auth().currentUser {
                self.getProfileDataDocument(user: user)
                self.monitorAndGetProfileImageDocument(user: user)
            }
        }
    }

    private func getProfileDataDocument(user: User) {
        Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument").getDocument { snap, error in
            if let error = error {
                print("取得失敗\(error)")
            }
            //                Retrieves all fields in the document as an `NSDictionary`. Returns `nil` if the document doesn't exist.
            //                Declaration
            //                func data() -> [String : Any]?
            if let profileData = snap?.data() {
                self.profileData = profileData
            }
            self.setProfileDataOnLabels(profileData: self.profileData)
            SVProgressHUD.dismiss()
        }
    }

//    monitor the updata of profile images in "profileImages" collection in database
    private func monitorAndGetProfileImageDocument(user: User) {
        let imageRef = Firestore.firestore().collection(FireBaseRelatedPath.imagePathForDB).document("\(user.uid)'sProfileImage")
        self.listener = imageRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("プロフィール画像の取得失敗\(error)")
            }
            if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
                let profileImageInfo = data["isProfileImageExisted"] as! String?
                if profileImageInfo != "nil" {
                    self.setImageFromStorage()
                } else {
                    self.imageView.image = UIImage(systemName: "person")
                }
            } else {
                self.imageView.image = UIImage(systemName: "person")
            }
        }
    }

    private func setImageFromStorage() {
        // retrieve images from storage and place them in imageView
        let user = Auth.auth().currentUser!
        let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")
        imageRef.downloadURL { url, error in
            if let error = error {
                print("URLの取得失敗\(error)")
            }
            if let url = url {
                print("URLの取得成功: \(url)")
                self.imageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
            }
            // update the cash with SDWebImageOptions.refreshedCashed
        }
    }

    private func setRightBarButtonItem() {
        self.secondTabBarController.rightBarButtonItems = []
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        let rightEdgeBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(self.tappedRightEdgeBarButtonItem(_:)))
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.circle"), style: .plain, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        self.rightBarButtonItem = rightBarButtonItem
        self.rightEdgeBarButtonItem = rightEdgeBarButtonItem
        self.secondTabBarController.rightBarButtonItems.append(rightEdgeBarButtonItem)
        self.secondTabBarController.rightBarButtonItems.append(rightBarButtonItem)
        self.secondTabBarController.navigationItem.rightBarButtonItems = self.secondTabBarController.rightBarButtonItems
        self.secondTabBarController.title = "プロフィール"
    }

    private func settingsForLabelsAndButtons() {
        self.likeNumberLabel.text = ""
        self.postNumberLabel.text = ""
        self.userNameLabel.text = "ー"
        self.genderLabel.text = "ー"
        self.ageLabel.text = "ー"
        self.workLabel.text = "ー"

        self.label1.text = "アカウントを作成/ログインしてください"
        let image = UIImage(systemName: "person")
        self.imageView.image = image

        self.rightBarButtonItem.isEnabled = false
        self.changePhotoButton.isEnabled = false
    }

    private func setProfileDataOnLabels(profileData _: [String: Any]) {
        self.userNameLabel.text = Auth.auth().currentUser?.displayName!
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

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        //  to EditProfileViewController
        if segue.identifier == "ToEditProfile" {
            let editProfileViewController = segue.destination as! EditProfileViewController
            editProfileViewController.profileViewController = self
            editProfileViewController.secondTabBarController = self.secondTabBarController
        }
    }

//    called when change / delete photo button was tapped
    private func configureMenuButton() {
        let items = UIMenu(title: "", children: [
            UIAction(title: "変更する", image: nil, handler: { _ in
                // open photo library
                self.openLibrary()
            }),
            UIAction(title: "削除する", image: nil, handler: { _ in
                self.writeTheInforForProfileImageToDatabase(isProfileImageExisted: false, imageUrlString: "nil")
            }),
        ])
        self.changePhotoButton.menu = UIMenu(title: "", options: .displayInline, children: [items])
        self.changePhotoButton.showsMenuAsPrimaryAction = true
    }

    private func openLibrary() {
        // open photo library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }

    // method called when a photo is taken/selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // close UIImagePickerController
        picker.dismiss(animated: true, completion: nil)
        // Image Processing
        if info[.originalImage] != nil {
            // Get the taken/selected image
            let image = info[.originalImage] as! UIImage
            // process the image
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }
    }

    // Method called when processing is finished in CLImageEditor
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        editor.dismiss(animated: true, completion: { () in
            self.image = image
            self.imageView.image = self.image
            self.saveImageToStorage()
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

//    Tap the Change Profile Image button
//    Update the image in storage
//    At the same time, your posts in the database (your post document data “profileImage" in the “posts” collection, your comment document data “profileImage" in the “comments" collection, and your profile “profileImage” in the “chatlists” collection) will be updated.
//    This will cause the database to monitor for updates and change the profile image that's gonna be displayed.
    private func saveImageToStorage() {
        // convert the profile image into JPEG type
        let imageData = self.image.jpegData(compressionQuality: 0.75)
        // location of the image file
        let user = Auth.auth().currentUser!
        let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child(user.uid + ".jpg")

        SVProgressHUD.show()
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metaData) { metadata, error in
            if error != nil {
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                return
            }
            if metadata != nil {
                print("画像のアップロードに成功しました")
                // if the user changed thier profile image and updated thier image that has already exsisted, specify "true" as a parameter
                // if the user delete thier image that has already exsited, the defult image (UIImage(sysyteName: "person")) will be set in the imageView automatically, in that case, "false" will be specified as a parameter
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("画像変更時のurl取得失敗\(error)")
                    }
                    if let imageUrl = url {
                        print("画像変更時のurl取得成功")
                        self.writeTheInforForProfileImageToDatabase(isProfileImageExisted: true, imageUrlString: imageUrl.absoluteString)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }

    // this process is for setting a image in the imageView in ProfileViewController
    private func writeTheInforForProfileImageToDatabase(isProfileImageExisted: Bool, imageUrlString: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let imageRef = Firestore.firestore().collection(FireBaseRelatedPath.imagePathForDB).document("\(user.uid)'sProfileImage")
        //        if "profileImageIsSet" has uid, it means that you set your own  profileImage, if it doesn't, it means that you are not setting your own profileImage, and in that case, default profile image UIImage(systemName: "person") will be displayed in the imageView
        var imageDic: [String: Any] = [:]
        if isProfileImageExisted {
            imageDic = [
                "isProfileImageExisted": imageUrlString,
            ]
        }
        if isProfileImageExisted == false {
            imageDic = ["isProfileImageExisted": "nil"]
        }
        imageRef.setData(imageDic) { error in
            if let error = error {
                print("databaseへのプロフィール画像の書き込み失敗\(error)")
            } else {
                print("databaseへのプロフィール画像の書き込み成功")
                self.updateMyDocumentsInPostsAndCommentsAndChatListsCollection(isProfileImageExisted: isProfileImageExisted, imageUrlString: imageUrlString)
            }
        }
    }

//    excute async processes
    private func updateMyDocumentsInPostsAndCommentsAndChatListsCollection(isProfileImageExisted: Bool, imageUrlString: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
//        an array which stroes the retrived documentId

        // an array which contains documentId in posts collection
        var docIdArrForPosts: [String] = []
        // an array which contains documentId in comments collection
        var docIdArrForComments: [String] = []

        // update my document in "posts" collection
        dispatchGroup.enter()
        dispatchQueue.async {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid)
            postsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("postsコレクション内のドキュメントの取得に失敗しました　エラー内容：\(error)")
                }

                if let querySnapshot = querySnapshot {
                    var excuteLeaveWhen0: Int = querySnapshot.documents.count
                    print("postsコレクション内のドキュメントの取得に成功しました")
                    if excuteLeaveWhen0 == 0 {
                        print("postsコレクション内のドキュメントの取得に成功しましたが、ドキュメントが空だったため、returnして、leave()を実行します。")
                        dispatchGroup.leave()
                        return
                    }

                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        docIdArrForPosts.append(queryDocumentSnapshot.documentID)
                        excuteLeaveWhen0 = excuteLeaveWhen0 - 1
                        if excuteLeaveWhen0 == 0 {
                            switch docIdArrForPosts.isEmpty {
                            case true:
                                print("空だったため、postsコレクション内のprofileImageの更新不要 leave実行")
                                dispatchGroup.leave()
                            case false:
                                print("postsコレクション内のprofileImageの更新開始 leaveを実行")
                                self.updateProfileImageInEachDocumentsInPostsCollection(user: user, docIdArrForPosts: docIdArrForPosts, isProfileImageExisted: isProfileImageExisted, imageUrlString: imageUrlString)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
        }

        // update my document in "comments" collection
        dispatchGroup.enter()
        dispatchQueue.async {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: user.uid)
            commentsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("commentsコレクション内のドキュメントの取得に失敗しました \(error)")
                }
                if let querySnapshot = querySnapshot {
                    var excuteLeaveWhenZero: Int = querySnapshot.documents.count
                    print("commentsコレクション内のドキュメントの取得に成功しました")
                    if excuteLeaveWhenZero == 0 {
                        print("commentsコレクション内のドキュメントの取得に成功しましたが、ドキュメントが空だったため、returnして、leave()を実行します。")
                        dispatchGroup.leave()
                        return
                    }
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        docIdArrForComments.append(queryDocumentSnapshot.documentID)
                        excuteLeaveWhenZero = excuteLeaveWhenZero - 1
                        if excuteLeaveWhenZero == 0 {
                            switch docIdArrForComments.isEmpty {
                            case true:
                                print("空だったため、commentsコレクション内のprofileImageの更新不要 leave実行")
                                dispatchGroup.leave()
                            case false:
                                print("commentsコレクション内のprofileImageの更新開始 leaveを実行")
                                self.updateProfileImageInEachDocumentsInCommentsCollection(user: user, docIdArrForComments: docIdArrForComments, isProfileImageExisted: isProfileImageExisted, imageUrlString: imageUrlString)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("複数の非同期処理完了")
        }
    }

    // update the "profileImage" of each of the documentId in the docIdArrForPosts
    private func updateProfileImageInEachDocumentsInPostsCollection(user _: User, docIdArrForPosts: [String], isProfileImageExisted: Bool, imageUrlString: String) {
        for documentId in docIdArrForPosts {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(documentId)
            var postDic: [String: Any] = [:]
            if isProfileImageExisted {
                postDic = [
                    "isProfileImageExisted": imageUrlString,
                ]
            }
            if isProfileImageExisted == false {
                postDic = [
                    "isProfileImageExisted": "nil",
                ]
            }
            postsRef.updateData(postDic) { error in
                if let error = error {
                    print("postsコレクション内のprofileImageの更新に失敗しました エラー内容：\(error)")
                } else {
                    print("postsコレクション内のprofileImageの更新に成功しました")
                    self.reloadTableView()
                }
            }
        }
    }

    // update the "profileImage" of each of the documentId in the docIdArrForComments
    private func updateProfileImageInEachDocumentsInCommentsCollection(user _: User, docIdArrForComments: [String], isProfileImageExisted: Bool, imageUrlString: String) {
        for documentId in docIdArrForComments {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(documentId)
            var commentDic: [String: Any] = [:]
            if isProfileImageExisted {
                commentDic = [
                    "isProfileImageExisted": imageUrlString,
                ]
            }
            if isProfileImageExisted == false {
                commentDic = [
                    "isProfileImageExisted": "nil",
                ]
            }
            postsRef.updateData(commentDic) { error in
                if let error = error {
                    print("commentsコレクション内のprofileImageの更新に失敗しました エラー内容：\(error)")
                } else {
                    print("commentsコレクション内のprofileImageの更新に成功しました")
                    self.reloadTableView()
                }
            }
        }
    }

    private func reloadTableView() {
        if let postsHistoryViewController = postsHistoryViewController {
            postsHistoryViewController.tableView.reloadData()
        }
        if let postedCommentsHistoryViewController = postedCommentsHistoryViewController {
            postedCommentsHistoryViewController.tableView.reloadData()
        }
        if let bookMarkViewController = bookMarkViewController {
            bookMarkViewController.tableView.reloadData()
        }
        if let commentsHistoryViewController = commentsHistoryViewController {
            commentsHistoryViewController.tableView.reloadData()
        }
        if let bookMarkCommentsSectionViewController = bookMarkCommentsSectionViewController {
            bookMarkCommentsSectionViewController.tableView.reloadData()
        }
    }

    private func getToday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.listener?.remove()
    }
}

extension ProfileViewController: setLikeAndPostNumberLabelDelegate {
    // display the number of likes and comments
    func setLikeAndPostNumberLabel(likeNumber: Int, postNumber: Int) {
        self.likeNumberLabel.text = "いいね \(String(likeNumber))"
        self.postNumberLabel.text = "投稿 \(String(postNumber))"
    }
}
