//
//  PostsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/30.
//

import Alamofire
import CoreMIDI
import Firebase
import SVProgressHUD
import UIKit

class PostsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postArray: [PostData] = []

    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        self.tableView.allowsSelection = true
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if let user = Auth.auth().currentUser {
            //            複合インデックスを作成する必要がある
            //            クエリで指定している複数のインデックスをその順にインデックスに登録する
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid).order(by: "postedDate", descending: true)
            postsRef.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                print("データかくにん\(self.postArray)")
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
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
        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)
        cell.cellEditButton.addTarget(self, action: #selector(self.tappedCellEfitButton(_:forEvent:)), for: .touchUpInside)
        cell.cellEditButton.isEnabled = true
        cell.cellEditButton.isHidden = false
        return cell
    }

    @objc func tappedCellEfitButton(_: UIButton, forEvent event: UIEvent) {
        //        投稿内容削除処理
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { _ in
            // 削除機能のコード
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: point)

            let postData = self.postArray[indexPath!.row]
            Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId).delete { error in
                if let error = error {
                    print("投稿データの削除失敗\(error)")
                } else {
                    print("投稿データの削除成功")
                }
            }

            Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId).collection("commentDataCollection").getDocuments { querySnapshot, error in
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
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func tappedHeartButton(_: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        print("postData確認\(postData)")

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let postData = self.postArray[indexPath.row]
        //        タップされたcellのドキュメントを取得
        self.performSegue(withIdentifier: "ToCommentsHistory", sender: postData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCommentsHistory" {
            let commentsHistoryViewController = segue.destination as! CommentsHistoryViewController
            commentsHistoryViewController.postData = sender as? PostData
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
