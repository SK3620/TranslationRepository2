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

    private var filteredArr: [String] = []

    var searchBar: UISearchBar?
    var searchBarText: String?

    // variable in order not to call getDocument method
    // stores Bool type value jsut as  determination
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
        self.label.text = ""

        if self.shouldExcuteGetDocumentMethod != true, self.searchBarText != nil {
            self.getDocuments(searchBarText: self.searchBarText!)
            self.secondPagingViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    // filtering
    // get all of the posted document data
    func getDocuments(searchBarText: String) {
        self.contentOfPostArray = []
        self.postArray = []
        self.searchBarText = searchBarText

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
                    // stores contentOfPost
                    let postDataForContentOfPost = PostData(document: document).contentOfPost
                    return postDataForContentOfPost!
                }
                self.filteredArr = []
                // String search with filter from contentOfPostArray that contains the contents of the post.
                self.filteredArr = self.contentOfPostArray.filter { $0.contains(searchBarText) }
                print(self.filteredArr)
                if self.filteredArr.isEmpty {
                    SVProgressHUD.showSuccess(withStatus: "検索結果 0件")
                    SVProgressHUD.dismiss(withDelay: 1.5)
                    self.tableView.reloadData()
                    return
                }
                self.getContentOfPostDocument(filteredArr: self.filteredArr)
            }
        })
    }

    // Conditional search from filteredArr with whereField, retrieve document, store in self.postArray
    private func getContentOfPostDocument(filteredArr: [String]) {
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
                        self.shouldExcuteGetDocumentMethod = true

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
                        self.getDocumentsWithoutSvProgress(searchBarText: self.searchBarText!)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let updateValue = FieldValue.arrayUnion([myid])
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                SVProgressHUD.showSuccess(withStatus: "ブックマークに登録しました")
                SVProgressHUD.dismiss(withDelay: 1.0, completion: {
                    postRef.updateData(["bookMarks": updateValue])
                    self.getDocumentsWithoutSvProgress(searchBarText: self.searchBarText!)
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
                self.getDocumentsWithoutSvProgress(searchBarText: self.searchBarText!)
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

    private func getDocumentsWithoutSvProgress(searchBarText: String) {
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
                    let postDataForContentOfPost = PostData(document: document).contentOfPost
                    return postDataForContentOfPost!
                }
                print("検索結果用のドキュメント\(self.contentOfPostArray)")

                self.filteredArr = []
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

    private func getContentOfPostDocumentWithoutSVProgress(filteredArr: [String]) {
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
