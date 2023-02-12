//
//  CertificationViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/10.
//

import Firebase
import MessageUI
import SVProgressHUD
import UIKit

// the function described here is almsot the same as the one in the TimeLineViewController
// the detail comments are written in TimeLineViewController, which I think may help you understand the code
// the one different function is filtering (doing a conditional search) when getting documents from firebase
class CertificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var label: UILabel!

    var secondTabBarController: SecondTabBarController!

    var secondPagingViewController: SecondPagingViewController!

    private var postArray: [PostData] = []

    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForTableView()

        if Auth.auth().currentUser == nil {
            self.screenTransitionToLoginViewController()
        }
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.borderColor = UIColor.clear.cgColor
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    private func screenTransitionToLoginViewController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        guard let user = Auth.auth().currentUser else {
            self.label.text = "アカウントを作成/ログインしてください"
            self.tableView.reloadData()
            return
        }
        self.label.text = ""

        GetDocument.getDocumentsForTimeline(user: user, topic: "資格試験", listener: self.listener) { result in
            switch result {
            case .success(let postArray):
                self.postArray = postArray
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            case .failure(let error):
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return self.postArray.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true

        cell.setPostData(self.postArray[indexPath.row])
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false

        if self.postArray[indexPath.row].uid == Auth.auth().currentUser?.uid {
            cell.cellEditButton.isEnabled = false
            cell.cellEditButton.isHidden = true
        }

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    @objc func tappedImageView1(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
        self.secondPagingViewController.postData = postData
        self.secondPagingViewController.segueToOthersProfile()
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
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

    @objc func tappedHeartButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
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

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        SVProgressHUD.show()
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
        UIPasteboard.general.string = postData.contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedCellEditButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let reportAction = UIAlertAction(title: "通報", style: .default) { _ in
            self.tappedReportButton(postData: postData)
        }
        let blockAction = UIAlertAction(title: "ブロック", style: .default) { _ in
            self.setUIAlert(postData: postData)
        }
        alert.addAction(reportAction)
        let user = Auth.auth().currentUser!
        if postData.uid != user.uid {
            alert.addAction(blockAction)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func setUIAlert(postData: PostData) {
        let alert = UIAlertController(title: "'\(postData.userName!)'さんをブロックしますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "はい", style: .destructive, handler: { _ in
            SVProgressHUD.showSuccess(withStatus: "'\(postData.userName!)'さんをブロックしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                let user = Auth.auth().currentUser!
                let uid = postData.uid
                BlockUnblock.blockUserInCommentsCollection(uid: uid!, user: user)
                BlockUnblock.blockUserInPostsCollection(uid: uid!, user: user)
                BlockUnblock.writeBlokedUserInFirestore(postData: postData, secondPostData: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let postData = self.postArray[indexPath.row]
        self.secondPagingViewController.postData = postData
//        screen transition to CommentSectionViewController
        self.secondPagingViewController.segue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // performed when the screen transtion to OthersPrifileViewController was performed
        if segue.identifier == "ToOthersProfile" {
            let othersProfileViewController = segue.destination as! OthersProfileViewController
            othersProfileViewController.postData = sender as? PostData
        }
    }
}

extension CertificationViewController: MFMailComposeViewControllerDelegate {
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
        let text = "【通報】投稿内容：\(postData.contentOfPost!)" + "\n" + "\n" + "documentId:\(postData.documentId)\nuid:\(postData.uid!)"
        mailViewController.setToRecipients(toRecipients) // 宛先メールアドレスの表示
        mailViewController.setCcRecipients(CcRecipients)
        mailViewController.setBccRecipients(BccRecipients)
        mailViewController.setMessageBody(text + "\n" + "内容：(ex.投稿内容が不適切。○○さんの追加コメントが不適切）", isHTML: false)
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
