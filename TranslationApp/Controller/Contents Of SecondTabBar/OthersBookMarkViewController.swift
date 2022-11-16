//
//  OthersBookMarkViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/09.
//

import Firebase
import SVProgressHUD
import UIKit

class OthersBookMarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postData: PostData!
    // 投稿データを格納する配列
    var postArray: [PostData] = []

    var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if Auth.auth().currentUser != nil {
            SVProgressHUD.show(withStatus: "データを読み込み中...")
            //            複合インデックスを作成する必要がある
            //            クエリで指定している複数のインデックスをその順にインデックスに登録する
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("bookMarks", arrayContains: self.postData.uid!).order(by: "postedDate", descending: true)
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
        self.performSegue(withIdentifier: "ToOthersBookMarkCommentsSection", sender: postData)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToOthersBookMarkCommentsSection" {
            let othersBookMarkCommentsSection = segue.destination as! OthersBookMarkCommentsSectionViewController
            othersBookMarkCommentsSection.postData = sender as? PostData
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
