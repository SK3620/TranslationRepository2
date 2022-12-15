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
    @IBOutlet var postCommentButton: UIBarButtonItem!
    //    タイムライン画面でタップされたcellの単一のドキュメント
    var postData: PostData!

    var listener: ListenerRegistration!

    var secondPostArray: [SecondPostData] = []

    var commentSectionViewController: CommentSectionViewController!
    var commentsHistoryViewController: CommentsHistoryViewController!
    var bookMarkCommentsSectionViewController: BookMarkCommentsSectionViewController?
    var othersCommentsHistoryViewController: OthersCommentsHistoryViewController?

    var textView_text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.postCommentButton.isEnabled = true

        self.textView.endEditing(false)
        self.setDoneToolBar()

        self.textView.text = self.textView_text

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

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

        if let textView_text = self.textView.text, let commentSectionViewController = self.commentSectionViewController {
            commentSectionViewController.comment = textView_text
        }

        if let textView_text = self.textView.text, let commentsHistroyViewController = self.commentsHistoryViewController {
            commentsHistroyViewController.comment = textView_text
        }

        if let textView_text = self.textView.text, let bookMarkCommentsSectionViewController = self.bookMarkCommentsSectionViewController {
            bookMarkCommentsSectionViewController.comment = textView_text
        }

        if let textView_text = self.textView.text, let othersCommentsHistoryViewController = self.othersCommentsHistoryViewController {
            othersCommentsHistoryViewController.comment = textView_text
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
        let user = Auth.auth().currentUser
        let textView_text = self.textView.text

        self.postCommentButton.isEnabled = false

        guard user != nil, textView_text!.isEmpty != true else {
            SVProgressHUD.showError(withStatus: "コメントを入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.postCommentButton.isEnabled = true
            return
        }

//        今日の日付を格納
        let today: String = self.getToday()

        if let user = Auth.auth().currentUser {
            let commentsDic = [
                "uid": user.uid,
                "userName": user.displayName!,
                "comment": textView_text!,
                "commentedDate": FieldValue.serverTimestamp(),
                "stringCommentedDate": today,
                "documentIdForPosts": self.postData.documentId,
            ] as [String: Any]
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document()
            commentsRef.setData(commentsDic, merge: false) { error in
                if let error = error {
                    print("”comments”にへの書き込み失敗\(error)")
                } else {
                    print("”comments”への書き込み成功")
                    self.excuteMultipleAsyncProcesses(textView_text: textView_text!, today: today)
                }
            }
        }

        //        uidとdisplayNameとコメント投稿日とコメント内容を格納する配列
//            更新データ作成
//        let postDic = [
//            "uid": user!.uid,
//            "userName": user!.displayName!,
//            "comment": textView_text!,
//            "commentedDate": FieldValue.serverTimestamp(),
//            "stringCommentedDate": today
//        ] as [String: Any]

//            ネスト化された配列にservserTimestampは使えないっぽい
//        Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").addDocument(data: postDic, completion: { error in
//            if let error = error {
//                print("エラー\(error)")
//                return
//            } else {
//                self.getDocumentIdForComments(uidCommentedDate: uidCommentedDate, textView_text: textView_text!)
//                self.wrtieCommentsInFireStore(textView_text: textView_text!, today: today)
//                self.getDocuments()
//                self.getDocuments()
//                self.excuteMultipleAsyncProcesses(textView_text: textView_text!, today: today)
//            }
//        })
    }

    func excuteMultipleAsyncProcesses(textView_text _: String, today _: String) {
        print("複数の非同期処理を実行します")
        let dispatchGroup = DispatchGroup()
        //        直列で実行
        let dispatchQueue = DispatchQueue(label: "queue")

//        dispatchGroup.enter()
//        dispatchQueue.async {
//            if let user = Auth.auth().currentUser {
//                let commentsDic = [
//                    "uid": user.uid,
//                    "userName": user.displayName!,
//                    "comment": textView_text,
//                    "commentedDate": FieldValue.serverTimestamp(),
//                    "stringCommentedDate": today,
//                    "documentIdForPosts": self.postData.documentId,
//                ] as [String: Any]
//                let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document()
//                commentsRef.setData(commentsDic, merge: false) { error in
//                    if let error = error {
//                        print("”comments”にへの書き込み失敗\(error)")
//                    } else {
//                        print("”comments”への書き込み成功")
//                        dispatchGroup.leave()
//                        print("一つ目のleave()を実行しました")
//                    }
//                }
//            }
//        }

        dispatchGroup.enter()
        dispatchQueue.async {
            if Auth.auth().currentUser != nil {
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
                let numberOfComments = String(self.secondPostArray.count)
                let postDic = [
                    "numberOfComments": numberOfComments,
                ]
                postRef.setData(postDic, merge: true) { error in
                    if let error = error {
                        print("エラーでした\(error)")
                    } else {
                        dispatchGroup.leave()
                        print("二つ目のleave()を実行しました")
                    }
                }
            }
        }

        dispatchGroup.enter()
        dispatchQueue.async {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: self.postData.documentId).order(by: "commentedDate", descending: true)
            commentsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("エラーでした、commentsコレクション内のドキュメントの取得に失敗しました\(error)")
                }
                if let querySnapshot = querySnapshot {
                    var excuteLeaveAtTheEnd: Int = querySnapshot.documents.count
                    print("commentsコレクション内のドキュメントの取得に成功しました")
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        self.secondPostArray.append(SecondPostData(document: queryDocumentSnapshot))
                        excuteLeaveAtTheEnd = excuteLeaveAtTheEnd - 1
                        if excuteLeaveAtTheEnd == 0 {
                            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
                            let numberOfComments = String(self.secondPostArray.count)
                            print("self.secondPostArray.count：\(self.secondPostArray.count)")
                            let postDic = [
                                "numberOfComments": numberOfComments,
                            ]
                            postRef.setData(postDic, merge: true) { error in
                                if let error = error {
                                    print("エラーでした\(error)")
                                } else {
                                    print("excuteLeaveATheEndのleave()を実行します")
                                    print(self.secondPostArray[0].comment)
                                    print(self.secondPostArray[0].commentedDate)
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                    //                    self.secondPostArray = querySnapshot.documents.map{ document in
                    //                        let secondPostData = SecondPostData(document: document)
                    //                        print("DEBUG_PRINT: snapshotの取得が成功しました。")
                    //                        return secondPostData
                    //                    }
                }
            }
        }

        //        dispatchGroup.enter()
        //        dispatchQueue.async {
        //            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
        //            let numberOfComments = String(self.secondPostArray.count)
        //            print("self.secondPostArray.count：\(self.secondPostArray.count)")
        //            let postDic = [
        //                "numberOfComments": numberOfComments,
        //            ]
        //            postRef.setData(postDic, merge: true) { error in
        //                if let error = error {
        //                    print("エラーでした\(error)")
        //                } else {
        //                    print("numberOfCommentsのupdateに成功しました、leave()を実行します")
        //                    dispatchGroup.leave()
        //                }
        //            }
        //        }

        dispatchGroup.notify(queue: .main) {
            print("非同期処理完了")

            if let commentSectionViewController = self.commentSectionViewController { commentSectionViewController.secondPostArray = self.secondPostArray
                print("日付確認")
                print(self.secondPostArray[0].commentedDate)
                print(self.secondPostArray[0].comment)
                print(self.secondPostArray[0].userName)
                print(self.secondPostArray[0].uid)
                print(self.secondPostArray[0].stringCommentedDate)

                commentSectionViewController.reloadTableView()
            }
            if let commentsHistroyViewController = self.commentsHistoryViewController {
                commentsHistroyViewController.secondPostArray = self.secondPostArray
                commentsHistroyViewController.reloadTableView()
            }

            if let bookMarkCommentsSectionViewController = self.bookMarkCommentsSectionViewController {
                bookMarkCommentsSectionViewController.secondPostArray = self.secondPostArray
                bookMarkCommentsSectionViewController.reloadTableView()
            }

            if let othersCommentsHistoryViewController = self.othersCommentsHistoryViewController {
                othersCommentsHistoryViewController.secondPostArray = self.secondPostArray
                othersCommentsHistoryViewController.reloadTableView()
            }
            SVProgressHUD.showSuccess(withStatus: "コメントしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                self.textView.text = ""
                self.textView.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

//    func getDocuments() {
    // ログイン済みか確認
//        if Auth.auth().currentUser != nil {
    // listenerを登録して投稿データの更新を監視する
    // いいねされたり、コメントが追加されれば、（更新されれば）呼ばれる
//            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId).collection("commentDataCollection").order(by: "commentedDate", descending: true)
//            print("postRef確認\(postsRef)")
//            self.listener = postsRef.addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
//                    return
//                }
    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
    //                mapの中のクロージャ引数documentはquerySnapshotDocumentで取り出された単一のドキュメント
//                self.secondPostArray = querySnapshot!.documents.map { document in
//                    print("DEBUG_PRINT: document取得 ここでは、自動生成（追加）されたドキュメントのIDがプリントされます。\(document.documentID)")
//                    let secondPostData = SecondPostData(document: document)
//                    print("DEBUG_PRINT: snapshotの取得が成功しました。")
//                    return secondPostData
//                }
//                print("self.secondPostArray確認する\(self.secondPostArray)")
//                self.writeNumberOfCommentsInFireStore()
//
//                if let commentSectionViewController = self.commentSectionViewController { commentSectionViewController.secondPostArray = self.secondPostArray
//                    commentSectionViewController.reloadTableView()
//                }
//                if let commentsHistroyViewController = self.commentsHistoryViewController {
//                    commentsHistroyViewController.secondPostArray = self.secondPostArray
//                    commentsHistroyViewController.reloadTableView()
//                }
//
//                if let bookMarkCommentsSectionViewController = self.bookMarkCommentsSectionViewController {
//                    bookMarkCommentsSectionViewController.secondPostArray = self.secondPostArray
//                    bookMarkCommentsSectionViewController.reloadTableView()
//                }
//
//                if let othersCommentsHistoryViewController = self.othersCommentsHistoryViewController {
//                    othersCommentsHistoryViewController.secondPostArray = self.secondPostArray
//                    othersCommentsHistoryViewController.reloadTableView()
//                }
//            }
//        }
//    }

//    投稿ボタンがおされたら、コメントしたドキュメントIDの数分をfirestoreにupdateData()で書き込むメソッド（コメント数の表示のため）
//    func writeNumberOfCommentsInFireStore() {
//        if Auth.auth().currentUser != nil {
//            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
//            let numberOfComments = String(self.secondPostArray.count)
//            let postDic = [
//                "numberOfComments": numberOfComments,
//            ]
//            postRef.setData(postDic, merge: true)
//            SVProgressHUD.showSuccess(withStatus: "コメントを投稿しました")
//            self.textView.text = ""
//        }
//    }

//    func getDocumentIdForComments(uidCommentedDate: String, textView_text: String){
//           if let user = Auth.auth().currentUser {
//               let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid/commentedDate", isEqualTo: uidCommentedDate)
//               commentsRef.getDocuments { querySnapshot, error in
//                   if let error = error {
//                       print("ドキュメントID取得失敗\(error)")
//                   }
//                   if let querySnapshot = querySnapshot {
//                       print("ドキュメントID取得成功")
    //   //                    このquerySnapshotは単一のドキュメント
//                       querySnapshot.documents.forEach { querySnapshotDocument in
//                           let documentIdForComments = querySnapshotDocument.documentID
//                           self.wrtieCommentsInFireStore(textView_text: textView_text, uidCommentedDate: uidCommentedDate, documentIdForComments: documentIdForComments)
//                       }
//                   }
//               }
//           }
//       }

//    新たなfirestoreの保存場所"comments"に、コメント内容などを書き込む
    func wrtieCommentsInFireStore(textView_text: String, today: String) {
        if let user = Auth.auth().currentUser {
            let commentsDic = [
                "uid": user.uid,
                "userName": user.displayName!,
                "comment": textView_text,
                "commentedDate": FieldValue.serverTimestamp(),
                "stringCommentedDate": today,
                "documentIdForPosts": self.postData.documentId,
            ] as [String: Any]
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document()
            SVProgressHUD.showSuccess(withStatus: "コメントしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                commentsRef.setData(commentsDic, merge: false) { error in
                    if let error = error {
                        print("”comments”にへの書き込み失敗\(error)")
                    } else {
                        print("”comments”への書き込み成功")
                        self.dismiss(animated: true)
                        self.textView.text = ""
                    }
                }
            }
        }
    }

//    今日の日付を返すメソッド
    func getToday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))
        let today = dateFormatter.string(from: date)
        return today
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
