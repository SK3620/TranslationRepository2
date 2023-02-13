//
//  SearchViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/17.
//

import Alamofire
import Firebase
import Parchment
import SVProgressHUD
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var label: UILabel!

    var secondTabBarController: SecondTabBarController!

    var secondPagingViewController: SecondPagingViewController!

//    stores content of posts
    private var contentOfPostArray: [String] = []

    private var postArray: [PostData] = []

    var listener: ListenerRegistration?

    var searchBar: UISearchBar?
    var searchBarText: String?

    // variable in order not to call getDocument method
    // stores Bool type value jsut as  determination
//    この変数は気にしなくていいです
    var shouldExcuteGetDocumentMethod: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForTableView()

        if Auth.auth().currentUser == nil {
            self.screenTransitionToLoginViewController()
        }
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.borderColor = UIColor.clear.cgColor
        let nib = UINib(nibName: "CustomCellForTimeLine", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    private func screenTransitionToLoginViewController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        self.present(loginViewController, animated: true, completion: nil)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        guard Auth.auth().currentUser != nil else {
            self.label.text = "アカウントを作成/ログインしてください"
            self.tableView.reloadData()
            return
        }

        if self.shouldExcuteGetDocumentMethod != true, self.searchBarText != nil {
            self.secondPagingViewController.navigationController?.setNavigationBarHidden(false, animated: false)
            self.getDocument(serachBarText: self.searchBarText!)
        }
        self.label.text = ""
    }

    func getDocument(serachBarText _: String) {
        let sentence = self.nGram(input: self.searchBarText!, n: 2)
        guard let sentence = sentence else {
            print("nGramが空でした")
            SVProgressHUD.showSuccess(withStatus: "検索結果 0件")
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.postArray = []
            self.tableView.reloadData()
            return
        }

        sentence.forEach { sentence in
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("nGram", arrayContains: sentence)
            self.listener = postsRef.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("全文検索機能エラー\(error)")
                }
                if let querySnapshot = querySnapshot {
                    print("全文検索機能ドキュメント取得成功")
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        self.postArray.append(PostData(document: queryDocumentSnapshot))
                        SVProgressHUD.showSuccess(withStatus: "検索結果 \(self.postArray.count)件")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        self.tableView.reloadData()
                        self.shouldExcuteGetDocumentMethod = true
                    }
                }
            }
        }
    }

    private func nGram(input: String, n: Int) -> [String]? {
        // nの数が文字列の文字数より多くなってしまうとエラーになるためreturnさせる
        guard input.count >= n else {
            print("nにはinputの文字数以下の整数値を入れてください")
            return nil
        }
        // 取り出した文字を格納する配列を宣言
        var sentence: [String] = []
        // inputの0番目のindexを宣言しておく
        let zero = input.startIndex

        // inputの文字数-n回ループする
        for i in 0 ... (input.count - n) {
            // 取り出す文字の先頭の文字のindexを定義
            let start = input.index(zero, offsetBy: i)
            // 取り出す文字の末尾の文字+1のindexを定義
            let end = input.index(start, offsetBy: n)
            // 指定した範囲で文字列を取り出す
            // endを含むと範囲からはみ出るためend未満の範囲を指定する
            // input[start..<end]の返り値はSubstring型のためString型にキャストする
            let addChar = String(input[start ..< end])
            // 取り出した文字列を配列に追加する
            sentence.append(addChar)
        }
        // 分割した文字列を出力する
        print(sentence)
        return sentence
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
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
        cell.cellEditButton.isEnabled = false
        cell.cellEditButton.isHidden = true

        cell.heartButton.addTarget(self, action: #selector(self.tappedHeartButton(_:forEvent:)), for: .touchUpInside)

        cell.bookMarkButton.addTarget(self, action: #selector(self.tappedBookMarkButton(_:forEvent:)), for: .touchUpInside)

        cell.buttonOnImageView1.addTarget(self, action: #selector(self.tappedImageView1(_:forEvent:)), for: .touchUpInside)

        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }

    @objc func tappedImageView1(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]
        self.secondPagingViewController.postData = postData
        self.secondPagingViewController.segueToOthersProfile()
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        if let myid = Auth.auth().currentUser?.uid {
            if postData.isBookMarked {
                let alert = UIAlertController(title: "ブックマークへの登録を解除しますか？", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "解除", style: .default, handler: { _ in
                    let updateValue = FieldValue.arrayRemove([myid])
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                    SVProgressHUD.showSuccess(withStatus: "登録解除")
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        postRef.updateData(["bookMarks": updateValue])
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let updateValue = FieldValue.arrayUnion([myid])
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                SVProgressHUD.showSuccess(withStatus: "ブックマークに登録しました")
                SVProgressHUD.dismiss(withDelay: 1.0, completion: {
                    postRef.updateData(["bookMarks": updateValue])
                })
            }
        }
    }

    @objc func tappedHeartButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if postData.isLiked {
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue]) { error in
                if error != nil {
                    return
                }
            }
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        UIPasteboard.general.string = postData.contentOfPost
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
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

//    private func getDocumentsWithoutSvProgress(searchBarText: String) {
//        self.contentOfPostArray = []
//        self.postArray = []
//        self.searchBarText = searchBarText
//
//        Firestore.firestore().collection(FireBaseRelatedPath.PostPath).getDocuments(completion: { querySnapshot, error in
//            if let error = error {
//                print("検索結果用のドキュメントの取得に失敗しました\(error)")
//
//                return
//            }
//            if let querySnapshot = querySnapshot {
//                print("検索結果用のドキュメント取得に成功しました")
//                self.contentOfPostArray = querySnapshot.documents.map { document in
//                    let postDataForContentOfPost = PostData(document: document).contentOfPost
//                    return postDataForContentOfPost!
//                }
//                print("検索結果用のドキュメント\(self.contentOfPostArray)")
//
//                self.filteredArr = self.contentOfPostArray.filter { $0.contains(searchBarText) }
//                if self.filteredArr.isEmpty {
//                    //                    self.postArray = []
//                    self.tableView.reloadData()
//                    return
//                }
//                self.getContentOfPostDocumentWithoutSVProgress(filteredArr: self.filteredArr)
//            }
//        })
//    }
//
//    private func getContentOfPostDocumentWithoutSVProgress(filteredArr: [String]) {
//        for contentOfPost in filteredArr {
//            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("contentOfPost", isEqualTo: contentOfPost).order(by: "postedDate", descending: true)
//            postsRef.getDocuments(completion: { querySnapshot, error in
//                if let error = error {
//                    print("getContentOfPostDocumentメソッドのドキュメント取得に失敗しました\(error)")
//                }
//                if let querySnapshot = querySnapshot {
//                    print("getContentOfPostDocumentメソッドのドキュメント取得に成功しました")
//                    querySnapshot.documents.forEach { queryDocumentSnapshot in
//                        self.postArray.append(PostData(document: queryDocumentSnapshot))
//                        self.tableView.reloadData()
//                    }
//                }
//            })
//        }
//    }
}
