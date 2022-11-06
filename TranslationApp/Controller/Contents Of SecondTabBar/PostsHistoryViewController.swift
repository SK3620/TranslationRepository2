//
//  PostsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/30.
//

import Firebase
import SVProgressHUD
import UIKit

class PostsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postArray: [PostData] = []

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

        if Auth.auth().currentUser != nil {
            self.whereSelect()
        }
    }

//        自分のuidで絞り込んだドキュメントを取得
    func whereSelect() {
        if let user = Auth.auth().currentUser {
//            複合インデックスを作成する必要がある
//            クエリで指定している複数のインデックスをその順にインデックスに登録する
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath)
            postsRef.whereField("uid", isEqualTo: user.uid).order(by: "postedDate", descending: true).getDocuments { queryDocuments, error in
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

                print(self.postArray)
                self.tableView.reloadData()
            }
        }
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
        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)
        return cell
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
