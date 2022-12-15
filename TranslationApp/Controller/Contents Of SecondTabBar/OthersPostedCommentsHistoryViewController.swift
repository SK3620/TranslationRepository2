//
//  OthersPostedCommentsHistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/08.
//

import Firebase
import SVProgressHUD
import UIKit

class OthersPostedCommentsHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var postData: PostData!
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

        self.navigationController?.setNavigationBarHidden(false, animated: false)

        SVProgressHUD.show(withStatus: "データ取得中...")
        if Auth.auth().currentUser != nil {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: self.postData.uid!).order(by: "commentedDate", descending: true)
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

        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true
        cell.bookMarkButton.isEnabled = false
        cell.bookMarkButton.isHidden = true
        cell.copyButton.isEnabled = false
        cell.copyButton.isHidden = true
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bubbleLabel.isHidden = true

        //        コメント吹き出しボタンをコピーボタンに変える。
        cell.bubbleButton.isEnabled = true
        cell.bubbleButton.isHidden = false
        cell.setButtonImage(button: cell.bubbleButton, systemName: "doc.on.doc")
        cell.bubbleButton.tintColor = .systemBlue
        cell.bubbleButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

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
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
