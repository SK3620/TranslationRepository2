//
//  PostedCommentsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/06.
//

//

import Firebase
import SVProgressHUD
import UIKit

// the screen which displays the comments you posted
class PostedCommentsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private var postArray: [PostData] = []

    var profileViewController: ProfileViewController?

    var listener: ListenerRegistration?

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
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if let profileViewController = self.profileViewController {
            profileViewController.postedCommentsHistoryViewController = self
        }

        guard let user = Auth.auth().currentUser else {
            self.postArray = []
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            return
        }

        GetDocument.getMyCommentsDocuments(uid: user.uid, listener: self.listener) { result in
            switch result {
            case let .failure(error):
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.dismiss()
            case let .success(postArray):
                self.postArray = postArray
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
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false
        cell.copyButton.isEnabled = false
        cell.copyButton.isHidden = true
        cell.bubbleLabel.isHidden = true

        //   change the bubble button to the copy button
        cell.bubbleButton.isEnabled = true
        cell.bubbleButton.isHidden = false
        cell.setButtonImage(button: cell.bubbleButton, systemName: "doc.on.doc")
        cell.bubbleButton.tintColor = .systemBlue
        cell.bubbleButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    @objc func tappedCellEditButton(_: UIButton, forEvent event: UIEvent) {
        // processes to delete the comments you posted
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { _ in
            SVProgressHUD.showSuccess(withStatus: "削除完了")
            SVProgressHUD.dismiss(withDelay: 1.0) {
                let touch = event.allTouches?.first
                let point = touch!.location(in: self.tableView)
                let indexPath = self.tableView.indexPathForRow(at: point)

                let postData = self.postArray[indexPath!.row]

                DeleteData.deleteCommentsData(postData: postData)
            }
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
}
