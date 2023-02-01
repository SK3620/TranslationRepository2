//
//  CommentViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import MessageUI
import SVProgressHUD
import UIKit

class CommentSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    var secondTabBarController: SecondTabBarController!

    var postData: PostData!
    var postArray: [PostData] = []
    var postData2: PostData?
    var secondPostArray: [SecondPostData] = []

    private var listener: ListenerRegistration?
    private var listener2: ListenerRegistration?

//    stores the documentID of the postData
    var documentId: String!

//    stores the input comment
    var comment: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "コメント欄"

        self.settingsForNavigationBarSppearence()

        self.settingsForTableView()
    }

    private func settingsForNavigationBarSppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        let nib2 = UINib(nibName: "CustomCellForCommentSetion", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "CustomCell2")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.settingsForNavigationControllerAndBar()

        if Auth.auth().currentUser != nil {
            self.getSingleDocument()

            self.getCommentsDocumentOnThePost()
        }
    }

    private func settingsForNavigationControllerAndBar() {
        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
    }

    private func getSingleDocument() {
        self.documentId = self.postData.documentId
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
        self.listener = postsRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            if let documentSnapshot = documentSnapshot {
                self.postArray = []
                let user = Auth.auth().currentUser!
                let postData = PostData(document: documentSnapshot)
                self.postData = postData
                self.postArray.append(postData)
                if postData.blockedBy.contains(user.uid) {
                    self.postArray = []
                }
                print("DEBUG_PRINT: snapshotの取得が成功しました。")
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        }
    }

    private func getCommentsDocumentOnThePost() {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: self.postData.documentId).order(by: "commentedDate", descending: true)
        self.listener2 = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            self.secondPostArray = []
            querySnapshot!.documents.forEach { queryDocumentSnapshot in
                let secondPostData = SecondPostData(document: queryDocumentSnapshot)
                let user = Auth.auth().currentUser!
                if secondPostData.blockedBy.contains(user.uid) {
                    print("ブロックしたユーザーのドキュメントを除外")
                } else {
                    self.secondPostArray.append(secondPostData)
                }
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
        self.listener2?.remove()
    }

    override func viewDidDisappear(_: Bool) {
        super.viewDidDisappear(true)
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.postArray.isEmpty {
            self.secondPostArray = []
        }
        if Auth.auth().currentUser != nil {
            return self.secondPostArray.count + self.postArray.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.commentButton.isEnabled = true
        cell.commentButton.isHidden = false
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false

        cell.commentButton.addTarget(self, action: #selector(self.tappedCommentButton), for: .touchUpInside)

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        if indexPath.row == 0 {
            cell.setPostData(self.postData)
            if self.postData.uid == Auth.auth().currentUser?.uid {
                cell.cellEditButton.isEnabled = false
                cell.cellEditButton.isHidden = true
            }
            return cell
        }

        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCellForCommentSetion

        cell2.cellEditButton.isEnabled = true
        cell2.cellEditButton.isHidden = false

        cell2.setSecondPostData(secondPostData: self.secondPostArray[indexPath.row - 1])

        if indexPath.row > 0, self.secondPostArray[indexPath.row - 1].uid == Auth.auth().currentUser?.uid {
            cell2.cellEditButton.isEnabled = false
            cell2.cellEditButton.isHidden = true
        }

        cell2.heartButton.addTarget(self, action: #selector(self.tappedHeartButtonInComment(_:forEvent:)), for: .touchUpInside)

        cell2.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButtonInComment(_:forEvent:)), for: .touchUpInside)

        cell2.copyButton.addTarget(self, action: #selector(self.tappedCopyButtonInCommentSection(_:forEvent:)), for: .touchUpInside)

        cell2.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1ForCell2(_:forEvent:)), for: .touchUpInside)

        cell2.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        cell2.bookMarkButton.isEnabled = false
        cell2.bookMarkButton.isHidden = true

        return cell2
    }

    @objc func tappedCommentButton() {
        let user = Auth.auth().currentUser!
        BlockUnblock.ifYouCanCommentOnThePost(postData: self.postData, user: user) { bool in
            if bool == false {
                return
            }
            let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "InputComment") as! UINavigationController
            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            let inputCommentViewContoller = navigationController.viewControllers[0] as! InputCommentViewController
            inputCommentViewContoller.postData = self.postData
            inputCommentViewContoller.commentSectionViewController = self
            inputCommentViewContoller.textView_text = self.comment
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData!

        if let myid = Auth.auth().currentUser?.uid {
            if postData.isBookMarked {
                let alert = UIAlertController(title: "ブックマークへの登録を解除しますか？", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "解除", style: .default, handler: { _ in
                    let updateValue = FieldValue.arrayRemove([myid])
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                    SVProgressHUD.showSuccess(withStatus: "登録解除")
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        postRef.updateData(["bookMarks": updateValue])
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let updateValue = FieldValue.arrayUnion([myid])
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                SVProgressHUD.showSuccess(withStatus: "ブックマークに登録しました")
                SVProgressHUD.dismiss(withDelay: 1.0, completion: {
                    postRef.updateData(["bookMarks": updateValue])
                })
            }
        }
    }

    @objc func tappedHeartButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData!

        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if postData.isLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    // bookmarking feature for comments here, isEnabled = false hiddne = true
    @objc func tappedBookMarkButtonInComment(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let secondPostData = self.secondPostArray[indexPath!.row - 1]
        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if secondPostData.isBookMarked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").document(secondPostData.documentId!)
            postRef.updateData(["bookMarks": updateValue])
        }
    }

    @objc func tappedHeartButtonInComment(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let secondPostData = self.secondPostArray[indexPath!.row - 1]

        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if secondPostData.isLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(secondPostData.documentId!)
            commentsRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent _: UIEvent) {
        UIPasteboard.general.string = self.postData.contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedCellEditButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let reportAction = UIAlertAction(title: "通報", style: .default) { _ in
            if indexPath?.row == 0 {
                self.tappedReportButton(postData: self.postData)
            } else {
                let secondPostData = self.secondPostArray[indexPath!.row - 1]
                self.tappedReportButtonInCommentSection(secondPostData: secondPostData)
            }
        }

        let blockAction = UIAlertAction(title: "ブロック", style: .default) { _ in
            if indexPath?.row == 0 {
                self.setUIAlert(postData: self.postData, secondPostData: nil)
            } else {
                let secondPostData = self.secondPostArray[indexPath!.row - 1]
                self.setUIAlert(postData: nil, secondPostData: secondPostData)
            }
        }
        alert.addAction(reportAction)
        let user = Auth.auth().currentUser!
        if indexPath?.row == 0, self.postData.uid != user.uid {
            alert.addAction(blockAction)
        }
        if indexPath?.row != 0, self.secondPostArray[indexPath!.row - 1].uid != user.uid {
            alert.addAction(blockAction)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func setUIAlert(postData: PostData?, secondPostData: SecondPostData?) {
        let user = Auth.auth().currentUser!
        var uid = ""
        var userName = ""
        if let postData = postData {
            uid = postData.uid!
            userName = postData.userName!
        }
        if let secondPostData = secondPostData {
            uid = secondPostData.uid!
            userName = secondPostData.userName!
        }
        let alert = UIAlertController(title: "'\(userName)'さんをブロックしますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "はい", style: .destructive, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "'\(userName)'さんをブロックしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                BlockUnblock.blockUserInCommentsCollection(uid: uid, user: user)
                BlockUnblock.blockUserInPostsCollection(uid: uid, user: user)
                BlockUnblock.writeBlokedUserInFirestore(postData: postData, secondPostData: secondPostData)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func tappedCopyButtonInCommentSection(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.secondPostArray[indexPath!.row - 1]
        UIPasteboard.general.string = postData.comment
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedImageView1(_: UIButton, forEvent _: UIEvent) {
        self.performSegue(withIdentifier: "ToOthersProfile", sender: self.postData)
    }

    @objc func tappedImageView1ForCell2(_: UIButton, forEvent event: UIEvent) {
        self.getDocumentForPostData2()
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let secondPostData = self.secondPostArray[indexPath!.row - 1]
        // Get the document ID of the retrieved data, and store the data retrieved in the whereField again in self.postData.
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(secondPostData.documentId!)
        postRef.getDocument(completion: { documentSnapshot, error in
            if let error = error {
                print("commentDataCollectionのドキュメント取得失敗\(error)")
            }
            if let documentSnapshot = documentSnapshot {
                self.postData = PostData(document: documentSnapshot)
                self.performSegue(withIdentifier: "ToOthersProfile", sender: self.postData)
            }
        })
    }

    func getDocumentForPostData2() {
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
        postRef.getDocument(completion: { documentSnapshot, error in
            if let error = error {
                print("getDocumentForPostData2メソッドでドキュメントの取得に失敗しました。\(error)")
            }
            if let documentSnapshot = documentSnapshot {
                print("getDocumentForPostData2メソッドでドキュメントの取得に成功しました")
                self.postData2 = PostData(document: documentSnapshot)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let otheresProfileViewController = segue.destination as! OthersProfileViewController
        otheresProfileViewController.postData = sender as? PostData
        otheresProfileViewController.documentId = self.documentId
        otheresProfileViewController.secondTabBarController = self.secondTabBarController
        otheresProfileViewController.commentSectionViewController = self
        if let postData2 = self.postData2 {
            otheresProfileViewController.postData2 = postData2
        }
    }
}

extension CommentSectionViewController: MFMailComposeViewControllerDelegate {
    private func tappedReportButton(postData: PostData) {
        //       check if the mail can be sent
        if MFMailComposeViewController.canSendMail() == false {
            print("Email Send Failed")
            return
        }

        guard let userEmail = Auth.auth().currentUser?.email else {
            print("メールアドレスの取得失敗")
            return
        }

        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["k-n-t1119@ezweb.ne.jp"]
        let CcRecipients = [userEmail]
        let BccRecipients = [userEmail]

        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("【通報】投稿内容：\(postData.contentOfPost!)" + "\n" + "\n" + "documentId:\(postData.documentId)\nuid:\(postData.uid!)")
        mailViewController.setToRecipients(toRecipients) // 宛先メールアドレスの表示
        mailViewController.setCcRecipients(CcRecipients)
        mailViewController.setBccRecipients(BccRecipients)
        mailViewController.setMessageBody("内容：(ex.投稿内容が不適切。○○さんの追加コメントが不適切）", isHTML: false)
        mailViewController.title = "【通報】"

        self.present(mailViewController, animated: true, completion: nil)
    }

    private func tappedReportButtonInCommentSection(secondPostData: SecondPostData) {
        //       check if the mail can be sent
        if MFMailComposeViewController.canSendMail() == false {
            print("Email Send Failed")
            return
        }

        guard let userEmail = Auth.auth().currentUser?.email else {
            print("メールアドレスの取得失敗")
            return
        }

        let mailViewController = MFMailComposeViewController()
        let toRecipients = ["k-n-t1119@ezweb.ne.jp"]
        let CcRecipients = [userEmail]
        let BccRecipients = [userEmail]

        mailViewController.mailComposeDelegate = self
        let text = "【通報】投稿内容：\(secondPostData.comment!)" + "\n" + "\n" + "documentId:\(secondPostData.documentId!)\nuid:\(secondPostData.uid!)"
        mailViewController.setToRecipients(toRecipients) // 宛先メールアドレスの表示
        mailViewController.setCcRecipients(CcRecipients)
        mailViewController.setBccRecipients(BccRecipients)
        mailViewController.setMessageBody(text + " \n" + "内容：(ex.投稿内容が不適切。○○さんの追加コメントが不適切）", isHTML: false)
        mailViewController.title = "【通報】"

        self.present(mailViewController, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email Send Cancelled")
        case .saved:
            print("Email Saved as a Draft")
        case .sent:
            print("Email Sent Successfully")
            SVProgressHUD.showSuccess(withStatus: "メールの送信に成功しました")
            SVProgressHUD.dismiss(withDelay: 1.5)
        case .failed:
            print("Email Send Failed")
            SVProgressHUD.showError(withStatus: "メールの送信に失敗しました")
            SVProgressHUD.dismiss(withDelay: 1.5)
            if let error = error {
                print("エラー内容:\(error)")
            }
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
 }
 */
