//
//  BookMarkViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Firebase
import SVProgressHUD
import UIKit

// the screen which dispalys data which you bookMarked
class BookMarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private var postArray: [PostData] = []

    private var listener: ListenerRegistration?

    var profileViewController: ProfileViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.settingsForTableView()
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.tableView.allowsSelection = true

        if let profileViewController = self.profileViewController {
            profileViewController.bookMarkViewController = self
        }

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if Auth.auth().currentUser == nil {
            self.postArray = []
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
            return
        }

        SVProgressHUD.show(withStatus: "データ取得中...")
        if let user = Auth.auth().currentUser {
            // get the documents filtered with bookMarks
            // the key 'bookMarks' has the array value which stores the uid of the person who tapped bookmark button
            self.listenerAndGetBookMarkedDocuments(user: user)
        }
    }

    private func listenerAndGetBookMarkedDocuments(user: User) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("bookMarks", arrayContains: user.uid).order(by: "postedDate", descending: true)
        self.listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
            }
            if let querySnapshot = querySnapshot {
                self.postArray = querySnapshot.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
            }
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.setPostData(self.postArray[indexPath.row])

        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        return cell
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
                SVProgressHUD.dismiss(withDelay: 1.0) {
                    postRef.updateData(["bookMarks": updateValue])
                }
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

        self.performSegue(withIdentifier: "ToBookMarkCommentsSection", sender: postData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToBookMarkCommentsSection" {
            let bookMarkCommentsSection = segue.destination as! BookMarkCommentsSectionViewController
            bookMarkCommentsSection.postData = sender as? PostData
            bookMarkCommentsSection.profileViewController = self.profileViewController
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
}
