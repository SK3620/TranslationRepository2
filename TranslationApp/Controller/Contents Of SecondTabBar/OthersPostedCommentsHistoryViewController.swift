//
//  OthersPostedCommentsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/08.
//

import Firebase
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

        SVProgressHUD.show(withStatus: "データ取得中...")
        if Auth.auth().currentUser != nil {
            self.listenerAndGetPostedCommentsDocuments()
        }
        if Auth.auth().currentUser == nil {
            self.postArray = []
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }

    private func listenerAndGetPostedCommentsDocuments() {
        let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: self.postData.uid!).order(by: "commentedDate", descending: true)
        self.listener = commentsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("querySnapshot取得失敗\(error)")
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            if let querySnapshot = querySnapshot {
                self.postArray = querySnapshot.documents.map { document in
                    let postData = PostData(document: document)
                    return postData
                }
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

        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true
        cell.bookMarkButton.isEnabled = false
        cell.bookMarkButton.isHidden = true
        cell.copyButton.isEnabled = false
        cell.copyButton.isHidden = true
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bubbleLabel.isHidden = true

        cell.bubbleButton.isEnabled = true
        cell.bubbleButton.isHidden = false
        cell.setButtonImage(button: cell.bubbleButton, systemName: "doc.on.doc")
        cell.bubbleButton.tintColor = .systemBlue

        cell.bubbleButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
