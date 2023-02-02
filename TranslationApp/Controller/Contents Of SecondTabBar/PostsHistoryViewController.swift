//
//  PostsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/30.
//

import Alamofire
import CoreMIDI
import Firebase
import FirebaseStorageUI
import Parchment
import SVProgressHUD
import UIKit

// delegateMethod to display the total number of likes and posts on the likeNumberLabel and commentNumberLabel in the ProfileViewController screen.
protocol setLikeAndPostNumberLabelDelegate: NSObject {
    func setLikeAndPostNumberLabel(likeNumber: Int, postNumber: Int)
}

class PostsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private var postArray: [PostData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var listener: ListenerRegistration?

    var delegate: setLikeAndPostNumberLabelDelegate!

    var profileViewController: ProfileViewController?

    // the total number of likes
    var likeNumber: Int = 0
    // the total number of commetns
    var postNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

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
            profileViewController.postsHistoryViewController = self
        }

        guard let user = Auth.auth().currentUser else {
            self.postArray = []
            self.tableView.reloadData()
            return
        }

        GetDocument.getMyDocuments(uid: user.uid, listener: self.listener) { postArray in
            SVProgressHUD.dismiss()
            self.postArray = postArray
            self.tableView.reloadData()

            self.likeNumber = 0
            self.postNumber = 0
            for postData in postArray {
                self.likeNumber += postData.likes.count
            }
            self.postNumber = self.postArray.count
            // delegate method
            self.delegate.setLikeAndPostNumberLabel(likeNumber: self.likeNumber, postNumber: self.postNumber)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEditButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        return cell
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
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { _ in
            DeleteData.deletePostsData(postData: postData)
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
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
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

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        let contentOfPost = postData.contentOfPost
        UIPasteboard.general.string = contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let postData = self.postArray[indexPath.row]
        self.performSegue(withIdentifier: "ToCommentsHistory", sender: postData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCommentsHistory" {
            let commentsHistoryViewController = segue.destination as! CommentsHistoryViewController
            commentsHistoryViewController.postData = sender as? PostData
            commentsHistoryViewController.profileViewController = self.profileViewController
        }
    }
}
