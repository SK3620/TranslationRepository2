//
//  BookMarkViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Firebase
import SVProgressHUD
import UIKit

class BookMarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    // 投稿データを格納する配列
    var postArray: [PostData] = []
//    var postArray2: [PostData] = []
//    var postArray: [[PostData]]!

//    var dosumentIdArray: [String] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration?
//    var listener2: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false

        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.tableView.allowsSelection = true

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        //        自分のuidで絞り込んだドキュメントを取得
        SVProgressHUD.show(withStatus: "データ取得中...")
        if let user = Auth.auth().currentUser {
            //            複合インデックスを作成する必要がある
            //            クエリで指定している複数のインデックスをその順にインデックスに登録する
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("bookMarks", arrayContains: user.uid).order(by: "postedDate", descending: true)
            self.listener = postsRef.addSnapshotListener { querySnapshot, error in

                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                }
                if let querySnapshot = querySnapshot {
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                }
                print("行われた")
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }

//            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document().collection("commentDataCollection").whereField("bookMarks", arrayContains: user.uid).order(by: "postedDate", descending: true)
//            この処理では、firebaseに定義された保存場所を取得できない .document()の部分がおそらくダメ。
        }
        if Auth.auth().currentUser == nil {
            self.postArray = []
            SVProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()
    }

    // セクション数を指定
//    func numberOfSections(in _: UITableView) -> Int {
//        if self.postArray1.isEmpty, self.postArray2.isEmpty {
//            return 0
//        } else {
//            return self.sections.count
//        }
//    }
//
//    // セクションタイトルを指定
//    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.sections[section]
//    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.setPostData(self.postArray[indexPath.row])

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent event: UIEvent) {
        print("bookMarkButtonが押された")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]

        // bookMarkを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
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

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        let contentOfPost = postData.contentOfPost
        UIPasteboard.general.string = contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let postData = self.postArray[indexPath.row]
        //        タップされたcellのドキュメントを取得
        self.performSegue(withIdentifier: "ToBookMarkCommentsSection", sender: postData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToBookMarkCommentsSection" {
            let bookMarkCommentsSection = segue.destination as! BookMarkCommentsSectionViewController
            bookMarkCommentsSection.postData = sender as? PostData
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
