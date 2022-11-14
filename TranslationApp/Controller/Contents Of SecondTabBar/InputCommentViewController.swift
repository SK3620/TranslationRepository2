//
//  InputCommentViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/04.
//

import Firebase
import SVProgressHUD
import UIKit

class InputCommentViewController: UIViewController {
    @IBOutlet var textView: UITextView!

//    タイムライン画面でタップされたcellの単一のドキュメント
    var postData: PostData!

    var listener: ListenerRegistration!

    var secondPostArray: [SecondPostData] = []

    var commentSectionViewController: CommentSectionViewController!

    var textView_text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.endEditing(false)
        self.setDoneToolBar()

        self.textView.text = self.textView_text

        // Do any additional setup after loading the view.
    }

    func setDoneToolBar() {
        // 決定バーの生成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        // インプットビュー設定

        self.textView.inputAccessoryView = toolbar
    }

    @objc func done() {
        self.textView.endEditing(true)
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()

        if let textView_text = self.textView.text {
            self.commentSectionViewController.comment = textView_text
        }

//        // ログイン済みか確認
//        if let user = Auth.auth().currentUser {
//            // listenerを登録して投稿データの更新を監視する
//            // いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
//            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("CommentDataCollection").order(by: "commentedDate", descending: true)
//            print("postRef確認\(postsRef)")
//            self.lisnter = postsRef.addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
//                    return
//                }
//                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
        ////                mapの中のクロージャ引数documentはquerySnapshotDocumentで取り出された単一のドキュメント
//                self.secondPostArray = querySnapshot!.documents.map { document in
//                    print("DEBUG_PRINT: document取得 ここでは、自動生成（追加）されたドキュメントのIDがプリントされます。\(document.documentID)")
//                    let secondPostData = SecondPostData(document: document)
//                    print("DEBUG_PRINT: snapshotの取得が成功しました。")
//                    return secondPostData
//                }
//            }
//        }
    }

//    コメント投稿ボタン
    @IBAction func postCommentButton(_: Any) {
        SVProgressHUD.show()

        let user = Auth.auth().currentUser
        let textView_text = self.textView.text

        guard user != nil, textView_text!.isEmpty != true else {
            SVProgressHUD.showError(withStatus: "コメントを入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }
        //        uidとdisplayNameとコメント投稿日とコメント内容を格納する配列
//            更新データ作成
        let postDic = [
            "uid": user!.uid,
            "userName": user!.displayName!,
            "comment": textView_text!,
            "commentedDate": FieldValue.serverTimestamp(),
        ] as [String: Any]

//            ネスト化された配列にservserTimestampは使えないっぽい
        Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").addDocument(data: postDic, completion: { error in
            if let error = error {
                print("追加失敗\(error)")
                return
            } else {
                print("追加成功")
                self.listner()
            }
        })
    }

    func listner() {
        print("リスナー")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            // いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").order(by: "commentedDate", descending: true)
            print("postRef確認\(postsRef)")
            self.listener = postsRef.addSnapshotListener { querySnapshot, error in
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
                print("self.secondPostArray確認する\(self.secondPostArray)")
                self.writeNumberOfCommentsInFireStore()
                self.commentSectionViewController.secondPostArray = self.secondPostArray
                self.commentSectionViewController.reloadTableView()
                self.textView.endEditing(true)
                SVProgressHUD.showSuccess(withStatus: "コメントしました")
                SVProgressHUD.dismiss(withDelay: 1.5, completion: { () in
                    self.dismiss(animated: true)
                })
            }
        }
    }

//    投稿ボタンがおされたら、コメントしたドキュメントIDの数分をfirestoreにupdateData()で書き込むメソッド（コメント数の表示のため）
    func writeNumberOfCommentsInFireStore() {
        if Auth.auth().currentUser != nil {
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
            let numberOfComments = String(self.secondPostArray.count)
            let postDic = [
                "numberOfComments": numberOfComments,
            ]
            postRef.setData(postDic, merge: true)
            SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
            self.textView.text = ""
        }
    }

//    更新データを作成
//
//                   let commentData = "\(name):\(contentOfComment)"
//
//           var updateValue: FieldValue
//           updateValue = FieldValue.arrayUnion([commentData])
//
//           let postsRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
//                       .updateData(["name&comment": updateValue])
//

    @IBAction func backButton(_: Any) {
        self.textView.endEditing(true)
        dismiss(animated: true)
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
