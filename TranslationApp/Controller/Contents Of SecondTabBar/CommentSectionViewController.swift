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
    var postData: PostData!
    var postData2: PostData?

    // Firestoreのリスナー
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    var secondPostArray: [SecondPostData] = []

//    postDataのdocumentIdを格納する
    var documentId: String!

//    入力したコメントを保持させる
    var comment: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray5
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

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

        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.secondTabBarController.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            //            タップされたドキュメントIDを指定　いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
            self.documentId = self.postData.documentId
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
                    self.tableView.reloadData()
                    print("tableViewがリロードされた1")
                }
            }
        }

        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
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
//        self.timeLineViewController.navigationController?.setNavigationBarHidden(true, animated: false)
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
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        cell.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1(_:forEvent:)), for: .touchUpInside)

        if indexPath.row == 0 {
            cell.setPostData(self.postData)
            print("postDataの値確認\(self.postData)")
            return cell
        }

        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCellForCommentSetion
        cell2.setSecondPostData(secondPostData: self.secondPostArray[indexPath.row - 1])
        print("secondPostDataの値確認\(self.secondPostArray)")
        cell2.heartButton.addTarget(self, action: #selector(self.tappedHeartButtonInComment(_:forEvent:)), for: .touchUpInside)
        cell2.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButtonInComment(_:forEvent:)), for: .touchUpInside)
        cell2.copyButton.addTarget(self, action: #selector(self.tappedCopyButtonInCommentSection(_:forEvent:)), for: .touchUpInside)
        cell2.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1ForCell2(_:forEvent:)), for: .touchUpInside)

        cell2.bookMarkButton.isEnabled = false
        cell2.bookMarkButton.isHidden = true

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

    @objc func tappedBookMarkButton(_: UIButton, forEvent _: UIEvent) {
        print("bookMarkButtonが押された")
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

    @objc func tappedHeartButton(_: UIButton, forEvent _: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
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

    @objc func tappedBookMarkButtonInComment(_: UIButton, forEvent event: UIEvent) {
        print("bookMarkButtonが押された")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let secondPostData = self.secondPostArray[indexPath!.row - 1]
        // bookMarkを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if secondPostData.isBookMarked {
                // すでにbookMarkをしている場合は、bookMark解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにbookmarkを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // bookMarksに更新データを書き込む
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").document(secondPostData.documentId!)
            postRef.updateData(["bookMarks": updateValue])
        }
    }

    @objc func tappedHeartButtonInComment(_: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let secondPostData = self.secondPostArray[indexPath!.row - 1]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if secondPostData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").document(secondPostData.documentId!)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent _: UIEvent) {
        // タップされたセルのインデックスを求める
//        投稿内容をコピー
        SVProgressHUD.show()
        // 配列からタップされたインデックスのデータを取り出す
        UIPasteboard.general.string = self.postData.contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
//            SVProgressHUD.dismiss()
//        }
    }

    @objc func tappedCopyButtonInCommentSection(_: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
//        コメント内容をコピー
        SVProgressHUD.show()
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.secondPostArray[indexPath!.row - 1]
        UIPasteboard.general.string = postData.comment
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
//            SVProgressHUD.dismiss()
//        }
    }

    //    プロフィール写真上のタップジェスチャー
    @objc func tappedImageView1(_: UIButton, forEvent _: UIEvent) {
        print("タップジェスチャー")
        self.performSegue(withIdentifier: "ToOthersProfile", sender: self.postData)
    }

    @objc func tappedImageView1ForCell2(_: UIButton, forEvent event: UIEvent) {
        self.getDocumentForPostData2()
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let secondPostData = self.secondPostArray[indexPath!.row - 1]
//        取り出したデータのドキュメントID取得して、再度whereFieldで取り出したデータをself.postDataへ格納する
        let documentId = secondPostData.documentId
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").document(documentId!)
        postRef.getDocument(completion: { documentSnapshot, error in
            if let error = error {
                print("commentDataCollectionのドキュメント取得失敗\(error)")
            }
            if let documentSnapshot = documentSnapshot {
                self.postData = PostData(document: documentSnapshot)

                self.performSegue(withIdentifier: "ToOthersProfile", sender: self.postData)
            }
        })
    }

    func getDocumentForPostData2() {
        print("getDocumentForPostData2メソッドが実行された")
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
        postRef.getDocument(completion: { documentSnapshot, error in
            if let error = error {
                print("getDocumentForPostData2メソッドでドキュメントの取得に失敗しました。\(error)")
            }
            if let documentSnapshot = documentSnapshot {
                print("getDocumentForPostData2メソッドでドキュメントの取得に成功しました")
                self.postData2 = PostData(document: documentSnapshot)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let otheresProfileViewController = segue.destination as! OthersProfileViewController
        otheresProfileViewController.postData = sender as? PostData
        otheresProfileViewController.documentId = self.documentId
        otheresProfileViewController.secondTabBarController = self.secondTabBarController
        otheresProfileViewController.commentSectionViewController = self

        if let postData2 = self.postData2 {
            otheresProfileViewController.postData2 = postData2
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
