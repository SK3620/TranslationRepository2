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
    // Firestoreのリスナー
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

        if let user = Auth.auth().currentUser {
            SVProgressHUD.show(withStatus: "データを読み込み中...")
            self.whereField()
        }
    }

    //        自分のuidで絞り込んだドキュメントを取得
    func whereField() {
        if let user = Auth.auth().currentUser {
            //            複合インデックスを作成する必要がある
            //            クエリで指定している複数のインデックスをその順にインデックスに登録する
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath)
            postsRef.whereField("bookMarks", arrayContains: user.uid).order(by: "postedDate", descending: true).getDocuments { queryDocuments, error in
                if let error = error {
                    print("絞り込みに失敗しました\(error)")
                }
                guard let queryDocuments = queryDocuments else {
                    print("絞り込み結果0件でした")
                    return
                }
                print("絞り込み結果がありました\(queryDocuments)")
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = queryDocuments.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                SVProgressHUD.dismiss()
                print(self.postArray)
                self.tableView.reloadData()
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
        if Auth.auth().currentUser != nil {
            return self.postArray.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForTimeLine
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true

        cell.setPostData(self.postArray[indexPath.row])
        cell.bookMarkButton.isEnabled = true
        cell.bookMarkButton.isHidden = false

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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
