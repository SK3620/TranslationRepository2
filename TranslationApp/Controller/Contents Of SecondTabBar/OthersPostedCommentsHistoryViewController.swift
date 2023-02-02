//
//  OthersPostedCommentsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/08.
//

import Firebase
import MessageUI
import SVProgressHUD
import UIKit

// function described here is almost the same as the one in PostedCommentsHistoryViewController
class OthersPostedCommentsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    var postData: PostData!

    private var postArray: [PostData] = []

    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForTableView()
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        self.tableView.allowsSelection = true
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        guard Auth.auth().currentUser != nil else {
            self.postArray = []
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            return
        }
        if Auth.auth().currentUser != nil {
            GetDocument.getMyCommentsDocuments(uid: self.postData.uid!, listener: self.listener) { postArray in
                self.postArray = postArray
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.listener?.remove()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.postArray.isEmpty {
            return 0
        } else {
            return self.postArray.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.setPostData(self.postArray[indexPath.row])

        cell.bookMarkButton.isEnabled = false
        cell.bookMarkButton.isHidden = true
        cell.copyButton.isEnabled = false
        cell.copyButton.isHidden = true
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bubbleLabel.isHidden = true
        cell.bubbleButton.isEnabled = true
        cell.bubbleButton.isHidden = false

        if self.postData.uid == Auth.auth().currentUser?.uid {
            cell.cellEditButton.isEnabled = false
            cell.cellEditButton.isHidden = true
        } else {
            cell.cellEditButton.isEnabled = true
            cell.cellEditButton.isHidden = false
        }

        cell.setButtonImage(button: cell.bubbleButton, systemName: "doc.on.doc")
        cell.bubbleButton.tintColor = .systemBlue

        cell.bubbleButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        return cell
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
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
        let comment = postData.comment
        UIPasteboard.general.string = comment
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
            BlockUnblock.determineIfHasAlreadyBeenBlocked(uid: postData.uid!) {
                SVProgressHUD.showSuccess(withStatus: "'\(postData.userName!)'さんをブロックしました")
                SVProgressHUD.dismiss(withDelay: 1.5) {
                    let user = Auth.auth().currentUser!
                    let uid = postData.uid
                    BlockUnblock.blockUserInCommentsCollection(uid: uid!, user: user)
                    BlockUnblock.blockUserInPostsCollection(uid: uid!, user: user)
                    BlockUnblock.writeBlokedUserInFirestore(postData: postData, secondPostData: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension OthersPostedCommentsHistoryViewController: MFMailComposeViewControllerDelegate {
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
        let text = "【通報】投稿内容：\(postData.comment!)" + "\n" + "\n" + "documentId:\(postData.documentId)\nuid:\(postData.uid!)"
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

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
 }
 */
