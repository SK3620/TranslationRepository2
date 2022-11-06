//
//  CommentViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import SVProgressHUD
import UIKit

class CommentSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var secondTabBarController: SecondTabBarController!
    var timeLineViewController: TimeLineViewController!
    var postData: PostData!
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    var secondPostArray: [SecondPostData] = []

//    入力したコメントを保持させる
    var comment: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.timeLineViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "詳細"

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        let nib2 = UINib(nibName: "CustomCellForCommentSetion", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "CustomCell2")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        // ログイン済みか確認
        if let user = Auth.auth().currentUser {
            // listenerを登録して投稿データの更新を監視する
            //            タップされたドキュメントIDを指定　いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
            print("postRef確認\(postsRef)")
//            単一のドキュメントが入ってる。
            self.listener = postsRef.addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }

                if let documentSnapshot = documentSnapshot {
                    self.postData = PostData(document: documentSnapshot)
                    print("DEBUG_PRINT: snapshotの取得が成功しました。")
                }
            }
        }

        // ログイン済みか確認
        if let user = Auth.auth().currentUser {
            // listenerを登録して投稿データの更新を監視する
            // いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").order(by: "commentedDate", descending: true)
            print("postRef確認\(postsRef)")
            self.listener2 = postsRef.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                //                mapの中のクロージャ引数documentはquerySnapshotDocumentで取り出された単一のドキュメント
                self.secondPostArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 ここでは、自動生成（追加）されたドキュメントのIDがプリントされます。\(document.documentID)")
                    let secondPostData = SecondPostData(document: document)
                    print("DEBUG_PRINT: snapshotの取得が成功しました。")

                    return secondPostData
                }
                self.tableView.reloadData()
                print("tableViewがリロードされた2")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()
        self.listener2?.remove()
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.timeLineViewController.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_: Bool) {
        super.viewDidDisappear(true)
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return self.secondPostArray.count + 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.commentButton.isEnabled = true
        cell.commentButton.isHidden = false
//        cell.commentButton.configuration?.title = "コメントする"
//        cell.commentButton.configuration?.subtitle = ""
//        cell.commentButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.commentButton.addTarget(self, action: #selector(self.tappedCommentButton), for: .touchUpInside)
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        if indexPath.row == 0 {
            cell.setPostData(self.postData)
            return cell
        }

        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCellForCommentSetion
        cell2.setSecondPostData(secondPostData: self.secondPostArray[indexPath.row - 1])
        return cell2
    }

    @objc func tappedCommentButton() {
        let navigationController = storyboard!.instantiateViewController(withIdentifier: "InputComment") as! UINavigationController
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        let inputCommentViewContoller = navigationController.viewControllers[0] as! InputCommentViewController
        inputCommentViewContoller.postData = self.postData
        inputCommentViewContoller.commentSectionViewController = self
        inputCommentViewContoller.textView_text = self.comment
        present(navigationController, animated: true, completion: nil)
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent event: UIEvent) {
        print("bookMarkButtonが押された")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postData!

        // bookMarkを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isBookMarked {
                // すでにbookMarkをしている場合は、bookMark解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにbookmarkを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // bookMarksに更新データを書き込む
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["bookMarks": updateValue])
        }
    }

    @objc func tappedHeartButton(_: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postData!
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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
