//
//  BookMarkCommentsSectionViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/09.
//

import Alamofire
import Firebase
import SVProgressHUD
import UIKit

class BookMarkCommentsSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postData: PostData!
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    var secondPostArray: [SecondPostData] = []
    var comment: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        let nib2 = UINib(nibName: "CustomCellForCommentSetion", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "CustomCell2")

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.setNavigationBarHidden(false, animated: true)

        SVProgressHUD.show(withStatus: "データ取得中")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
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
                    if self.postData.isBookMarked == false {
                        self.tableView.reloadData()
                    }
                }
                self.tableView.reloadData()
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
                    if self.postData.isBookMarked == false {
                        self.tableView.reloadData()
                    }
                    return secondPostData
                }

                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                print("tableViewがリロードされた2")
            }
        }
        if Auth.auth().currentUser == nil {
            SVProgressHUD.dismiss()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if Auth.auth().currentUser != nil, self.postData.isBookMarked == false {
            self.navigationController?.popViewController(animated: true)
            return 0
        }

        if Auth.auth().currentUser != nil {
            return self.secondPostArray.count + 1
        } else {
            return 0
        }
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine

        cell.commentButton.isEnabled = true
        cell.commentButton.isHidden = false
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)
        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)
        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(self.tappedCommentButton(_:forEvent:)), for: .touchUpInside)

        if indexPath.row == 0 {
            cell.setPostData(self.postData)
            return cell
        }

        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCellForCommentSetion
        cell2.setSecondPostData(secondPostData: self.secondPostArray[indexPath.row - 1])
        cell2.bookMarkButton.isEnabled = false
        cell2.bookMarkButton.isHidden = true

        cell2.heartButton.addTarget(self, action: #selector(self.tappedHeartButtonInComment(_:forEvent:)), for: .touchUpInside)
        cell2.copyButton.addTarget(self, action: #selector(self.tappedCopyButtonInComment(_:forEvent:)), for: .touchUpInside)

        return cell2
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

    @objc func tappedBookMarkButton(_: UIButton, forEvent _: UIEvent) {
        print("bookMarkButtonが押された")
        let postData = self.postData!

        if let myid = Auth.auth().currentUser?.uid {
            // bookMarkを更新する
            if postData.isBookMarked {
                let alert = UIAlertController(title: "ブックマークへの登録を解除しますか？", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "解除", style: .default, handler: { _ in
                    // すでにbookMarkをしている場合は、bookMark解除のためmyidを取り除く更新データを作成
                    let updateValue = FieldValue.arrayRemove([myid])
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                    SVProgressHUD.showSuccess(withStatus: "登録解除")
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        postRef.updateData(["bookMarks": updateValue])
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                // 今回新たにbookmarkを押した場合は、myidを追加する更新データを作成
                let updateValue = FieldValue.arrayUnion([myid])
                // bookMarksに更新データを書き込む
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                SVProgressHUD.showSuccess(withStatus: "ブックマークに登録しました")
                SVProgressHUD.dismiss(withDelay: 1.0) {
                    postRef.updateData(["bookMarks": updateValue])
                }
            }
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

            //            "commnets"コレクション内のlikesを更新
            let commnetsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: secondPostData.uid!).whereField("stringCommentedDate", isEqualTo: secondPostData.stringCommentedDate!)
            commnetsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("”comments”コレクション内のlikesの更新に失敗しました、エラー内容は\(error)")
                    SVProgressHUD.dismiss()
                    return
                }
                if let querySnapshot = querySnapshot {
                    print("”commentsコレクション内のlikesの更新に成功しました。")

                    if querySnapshot.isEmpty {
                        print("からでした")
                    }

                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        let documentId = SecondPostData(document: queryDocumentSnapshot).documentId

                        Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(documentId!).updateData(["likes": updateValue])
                    }
                }
            }
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent _: UIEvent) {
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postData
        let contentOfPost = postData!.contentOfPost
        UIPasteboard.general.string = contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedCopyButtonInComment(_: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let secondPostData = self.secondPostArray[indexPath!.row - 1]
        let comment = secondPostData.comment
        UIPasteboard.general.string = comment
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @objc func tappedCommentButton(_: UIButton, forEvent _: UIEvent) {
        let postData = self.postData
        let navigationController = storyboard!.instantiateViewController(withIdentifier: "InputComment") as! UINavigationController
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        let inputCommentViewContoller = navigationController.viewControllers[0] as! InputCommentViewController
        inputCommentViewContoller.postData = postData
        inputCommentViewContoller.bookMarkCommentsSectionViewController = self
        inputCommentViewContoller.textView_text = self.comment
        present(navigationController, animated: true, completion: nil)
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
