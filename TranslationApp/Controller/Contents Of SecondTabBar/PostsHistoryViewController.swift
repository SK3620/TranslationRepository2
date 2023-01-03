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

    private var postArray: [PostData] = []

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

        if Auth.auth().currentUser == nil {
            self.postArray = []
            self.tableView.reloadData()
            return
        }

        SVProgressHUD.show(withStatus: "データ取得中...")
        if let user = Auth.auth().currentUser {
            self.listenerAndGetDocumentsAndSettingsForTheNumberOflikesPostsLabel(user: user)
        }
    }

    private func listenerAndGetDocumentsAndSettingsForTheNumberOflikesPostsLabel(user: User) {
        //            複合インデックスを作成する必要がある
        //            クエリで指定している複数のインデックスをその順にインデックスに登録する
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid).order(by: "postedDate", descending: true)
        self.listener = postsRef.addSnapshotListener { querySnapshot, error in
            print("りすなー")
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            // Create PostData based on the acquired document and make it into a postArray array.
            self.postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            self.tableView.reloadData()
            SVProgressHUD.dismiss()

//                settings for the number of likes and posts
            self.likeNumber = 0
            self.postNumber = 0
            querySnapshot?.documents.forEach { queryDocumentSnapshot in
                self.likeNumber += PostData(document: queryDocumentSnapshot).likes.count
            }
            self.postNumber = self.postArray.count
            // delegate method
            self.delegate.setLikeAndPostNumberLabel(likeNumber: self.likeNumber, postNumber: self.postNumber)
        }
    }

    // こっから
    // monitor the update of user's profile image
//    private func monitorTheUpdateOfProfileImage() {
//        guard let user = Auth.auth().currentUser else {
//            return
//        }
//        let imageRef = Firestore.firestore().collection(FireBaseRelatedPath.imagePathForDB).document("\(user.uid)'sProfileImage")
//        self.listener2 = imageRef.addSnapshotListener { documentSnapshot, error in
//            if let error = error {
//                print("プロフィール画像の取得失敗\(error)")
//            }
//            if let documentSnapshot = documentSnapshot, let data = documentSnapshot.data() {
//                let profileImageInfo = data["isprofileImageExisted"] as! String?
//                if profileImageInfo != "nil" {
//                    self.setImageFromStorage()
//                } else {
//                    self.urlForProfileImage = nil
//                    self.tableView.reloadData()
//                }
//            } else {
//                self.urlForProfileImage = nil
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    private func setImageFromStorage() {
//        // retrieve images from storage and place them in imageView
//        let user = Auth.auth().currentUser!
//        let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")
//        imageRef.downloadURL { url, error in
//            if let error = error {
//                print("URLの取得失敗\(error)")
//            }
//            if let url = url {
//                print("URLの取得成功: \(url)")
//                self.urlForProfileImage = url
//                self.tableView.reloadData()
//            }
//            // update the cash with SDWebImageOptions.refreshedCashed
//        }
//    }

    // ここまで

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        print("リロードー")
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
            // precesses to delete
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "queue")

            SVProgressHUD.showSuccess(withStatus: "削除完了")
            SVProgressHUD.dismiss(withDelay: 1.0) {
                dispatchGroup.enter()
                dispatchQueue.async {
                    Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId).delete { error in
                        if let error = error {
                            print("投稿データの削除失敗\(error)")
                        } else {
                            print("投稿データの削除成功")
                            dispatchGroup.leave()
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: postData.documentId)

                    commentsRef.getDocuments { querySnapshot, error in
                        if let error = error {
                            print("コメントの取得失敗/またはコメントがありません\(error)")
                        }
                        if let querySnapshot = querySnapshot {
                            print("コメントを取得しました\(querySnapshot)")
                            querySnapshot.documents.forEach {
                                $0.reference.delete(completion: { error in
                                    if let error = error {
                                        print("コメント削除失敗\(error)")
                                    } else {
                                        print("コメント削除成功")
                                    }
                                })
                            }
                        }
                    }
                }
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
