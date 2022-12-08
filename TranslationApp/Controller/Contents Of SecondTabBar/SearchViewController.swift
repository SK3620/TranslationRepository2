//
//  SearchViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/17.
//

import Firebase
import Parchment
import SVProgressHUD
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var label: UILabel!

    var secondTabBarController: SecondTabBarController!
    var secondPagingViewController: SecondPagingViewController!
//    投稿内容を格納させる
    var contentOfPostArray: [String] = []
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    var filteredArr: [String] = []

    var secondPostArray: [SecondPostData] = []

    var searchBar: UISearchBar?
    var searchBarText: String?

    //  willAppearで、getDocumentsメソッドを実行させないために用意する変数
    var notExcuteGetDocumentMethod: SecondPagingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.borderColor = UIColor.clear.cgColor

        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        if Auth.auth().currentUser == nil {
            let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            //            loginViewController.logoutButton.isEnabled = false
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        //        ログインしていなければ、returnし、ログインまたはアカウント作成を促す
        guard Auth.auth().currentUser != nil else {
            self.label.text = "アカウントを作成/ログインしてください"
            self.tableView.reloadData()
            return
        }
        self.label.text = ""

        if self.notExcuteGetDocumentMethod == nil, self.searchBarText != nil {
            print("guard let 実行 \(self.searchBarText!)")
            self.getDocuments(searchBarText: self.searchBarText!)
            self.secondPagingViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

//    一度全ての投稿データのドキュメントを取得(whereFieldメソッドには、containsがない、arrayContainsは機能が違う）
    func getDocuments(searchBarText: String) {
        self.contentOfPostArray = []
        self.postArray = []
        self.searchBarText = searchBarText

        print("String確認\(searchBarText)")

        SVProgressHUD.show(withStatus: "データ取得中...")
        Firestore.firestore().collection(FireBaseRelatedPath.PostPath).getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("検索結果用のドキュメントの取得に失敗しました\(error)")
                SVProgressHUD.showInfo(withStatus: "エラー")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }
            if let querySnapshot = querySnapshot {
                print("検索結果用のドキュメント取得に成功しました")
                if querySnapshot.isEmpty {
                    print("querySnapshotが空でした")
                    SVProgressHUD.showSuccess(withStatus: "検索結果 0件")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    return
                }
                self.contentOfPostArray = querySnapshot.documents.map { document in
                    //                    投稿内容を格納させる
                    let postDataForContentOfPost = PostData(document: document).contentOfPost
                    return postDataForContentOfPost!
                }
                print("検索結果用のドキュメント\(self.contentOfPostArray)")
                self.filteredArr = []
                //    投稿内容を格納したcontentOfPostArrayから、filterで文字列検索する
                self.filteredArr = self.contentOfPostArray.filter { $0.contains(searchBarText) }
                print(self.filteredArr)
                if self.filteredArr.isEmpty {
                    SVProgressHUD.showSuccess(withStatus: "検索結果 0件")
                    SVProgressHUD.dismiss(withDelay: 1.5)
//                    self.postArray = []
                    self.tableView.reloadData()
                    return
                }
                self.getContentOfPostDocument(filteredArr: self.filteredArr)
            }
        })
    }

//    filteredArrからwhereFieldで条件検索して、ドキュメントを取り出し、self.postArrayへ格納
    func getContentOfPostDocument(filteredArr: [String]) {
        print(self.postArray)
        print(filteredArr)
        for contentOfPost in filteredArr {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("contentOfPost", isEqualTo: contentOfPost).order(by: "postedDate", descending: true)
            postsRef.getDocuments(completion: { querySnapshot, error in
                if let error = error {
                    print("getContentOfPostDocumentメソッドのドキュメント取得に失敗しました\(error)")
                    SVProgressHUD.showInfo(withStatus: "getContentOfPostDocumentメソッドのドキュメント取得失敗")
                }
                if let querySnapshot = querySnapshot {
                    print("getContentOfPostDocumentメソッドのドキュメント取得に成功しました")
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        self.postArray.append(PostData(document: queryDocumentSnapshot))

                        SVProgressHUD.showSuccess(withStatus: "検索結果 \(self.postArray.count)件")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        self.tableView.reloadData()
                        self.notExcuteGetDocumentMethod = nil

                        self.postArray.forEach {
                            print($0.documentId)
                        }
                    }
                }
            })
        }
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
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    //    プロフィール写真上のタップジェスチャー
    @objc func tappedImageView1(_: UIButton, forEvent event: UIEvent) {
        print("タップジェスチャー")
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        self.secondPagingViewController.postData = postData
        self.secondPagingViewController.segueToOthersProfile()
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
            postRef.updateData(["bookMarks": updateValue], completion: { error in
                if let error = error {
                    print("bookMarksへのupdate失敗\(error)")
                    return
                }
                self.getDocumentsWithoutSvProgress(searchBarText: self.searchBarText!)
            })
        }
    }

    @objc func tappedHeartButton(_: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        print("self.postArrayの値確認\(self.postArray)")
        let postData = self.postArray[indexPath!.row]
        print("postData確認値があるかな？\(postData.documentId)")

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
            postRef.updateData(["likes": updateValue]) { error in
                if let error = error {
                    print("likesへのupdate失敗\(error)")
                    return
                }
                self.getDocumentsWithoutSvProgress(searchBarText: self.searchBarText!)
            }
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
//        投稿内容をコピー
        SVProgressHUD.show()
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        UIPasteboard.general.string = postData.contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
//            SVProgressHUD.dismiss()
//        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let postData = self.postArray[indexPath.row]
        self.secondPagingViewController.postData = postData
        self.secondPagingViewController.segue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToOthersProfile" {
            let othersProfileViewController = segue.destination as! OthersProfileViewController
            othersProfileViewController.postData = sender as? PostData
        }
    }

    func getDocumentsWithoutSvProgress(searchBarText: String) {
        self.contentOfPostArray = []
        self.postArray = []
        self.searchBarText = searchBarText

        Firestore.firestore().collection(FireBaseRelatedPath.PostPath).getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("検索結果用のドキュメントの取得に失敗しました\(error)")

                return
            }
            if let querySnapshot = querySnapshot {
                print("検索結果用のドキュメント取得に成功しました")
                self.contentOfPostArray = querySnapshot.documents.map { document in
                    //                    投稿内容を格納させる
                    let postDataForContentOfPost = PostData(document: document).contentOfPost
                    return postDataForContentOfPost!
                }
                print("検索結果用のドキュメント\(self.contentOfPostArray)")

                self.filteredArr = []
                //    投稿内容を格納したcontentOfPostArrayから、filterで文字列検索する
                self.filteredArr = self.contentOfPostArray.filter { $0.contains(searchBarText) }
                if self.filteredArr.isEmpty {
                    //                    self.postArray = []
                    self.tableView.reloadData()
                    return
                }
                self.getContentOfPostDocumentWithoutSVProgress(filteredArr: self.filteredArr)
            }
        })
    }

//    filteredArrからwhereFieldで条件検索して、ドキュメントを取り出し、self.postArrayへ格納
    func getContentOfPostDocumentWithoutSVProgress(filteredArr: [String]) {
        for contentOfPost in filteredArr {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("contentOfPost", isEqualTo: contentOfPost).order(by: "postedDate", descending: true)
            postsRef.getDocuments(completion: { querySnapshot, error in
                if let error = error {
                    print("getContentOfPostDocumentメソッドのドキュメント取得に失敗しました\(error)")
                }
                if let querySnapshot = querySnapshot {
                    print("getContentOfPostDocumentメソッドのドキュメント取得に成功しました")
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        self.postArray.append(PostData(document: queryDocumentSnapshot))
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}
