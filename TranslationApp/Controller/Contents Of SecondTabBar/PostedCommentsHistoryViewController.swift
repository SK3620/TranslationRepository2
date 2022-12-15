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

class PostedCommentsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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

        SVProgressHUD.show(withStatus: "データ取得中")
        if let user = Auth.auth().currentUser {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: user.uid).order(by: "commentedDate", descending: true)
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
                        print("postArr実行")
                        return postData
                    }
                    SVProgressHUD.dismiss()
                    print("リロードした")
                    self.tableView.reloadData()
                }
            }
        }
        if Auth.auth().currentUser == nil {
            self.postArray = []
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
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

//        コメント吹き出しボタンをコピーボタンに変える。
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
        //        投稿内容削除処理
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { _ in
            // 削除機能のコード
            SVProgressHUD.showSuccess(withStatus: "削除完了")
            SVProgressHUD.dismiss(withDelay: 1.0) {
                let touch = event.allTouches?.first
                let point = touch!.location(in: self.tableView)
                let indexPath = self.tableView.indexPathForRow(at: point)

                let postData = self.postArray[indexPath!.row]
                self.excuteMultipleAsyncProcesses(postData: postData) { error in
                    print("エラーでした。エラー内容：\(error)")
                }
            }
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func excuteMultipleAsyncProcesses(postData: PostData, completion: @escaping (Error) -> Void) {
        let dispatchGruop = DispatchGroup()
        //        直列で実行 .concurrentではない
        let dispatchQueue = DispatchQueue(label: "queue")
        var updatedNumberOfComments = "0"

        dispatchGruop.enter()
        dispatchQueue.async {
            Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(postData.documentId).delete { error in
                if let error = error {
                    print("コメントデータの削除失敗")
                    completion(error)
                } else {
                    print("コメントデータの削除成功")
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: postData.documentIdForPosts!)
                    commentsRef.getDocuments { querySnapshot, error in
                        if let error = error {
                            print("エラーでした：エラー内容\(error)")
                        }
                        if let querySnapshot = querySnapshot {
                            updatedNumberOfComments = String(querySnapshot.documents.count)
                            dispatchGruop.leave()
                        }
                    }
                }
            }

            dispatchGruop.notify(queue: .main, execute: {
                //            コメント数の更新
                let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentIdForPosts!)
                let updatedPostDic = [
                    "numberOfComments": updatedNumberOfComments,
                ]
                postsRef.setData(updatedPostDic, merge: true) { error in
                    if let error = error {
                        print("updatedNumberOfCommentsの更新失敗")
                        completion(error)
                        return
                    } else {
                        print("updatedNumberOfCommentsの更新成功")
                        self.tableView.reloadData()
                    }
                }

            })
        }
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
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        let comment = postData.comment
        UIPasteboard.general.string = comment
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
    /*     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
