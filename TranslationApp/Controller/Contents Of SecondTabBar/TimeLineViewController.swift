//
//  TimeLineViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import Firebase
import SVProgressHUD
import UIKit

class TimeLineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var label: UILabel!

    var secondTabBarController: SecondTabBarController!

    var secondPagingViewController: SecondPagingViewController!

    // variable to store the posted data
    private var postArray: [PostData] = []

    // observe updated data and etc...
    private var listener: ListenerRegistration?

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

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // if you are not logged in, have you log in and create an account
        guard Auth.auth().currentUser != nil else {
            self.label.text = "アカウントを作成/ログインしてください"
            self.tableView.reloadData()
            return
        }
        self.label.text = ""

        self.listenrAndGetDocuments()
    }

    func listenrAndGetDocuments() {
        SVProgressHUD.show(withStatus: "データを取得中...")
        // confirm if you are logged in
        if Auth.auth().currentUser != nil {
            // Register a listener to monitor updates to posted data
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).order(by: "postedDate", descending: true)
            self.listener = postsRef.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                    return
                }
                // Create PostData based on the acquired document and make it into a postArray array.
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // delete remove and stop observing (monitoring)
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

    //    tap gestrue on the profile imageView
    @objc func tappedImageView1(_: UIButton, forEvent event: UIEvent) {
        // get the index of the tapped cell
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        // Retrieve the data at the tapped index from the array
        let postData = self.postArray[indexPath!.row]
        self.secondPagingViewController.postData = postData
        self.secondPagingViewController.segueToOthersProfile()
    }

    @objc func tappedBookMarkButton(_: UIButton, forEvent event: UIEvent) {
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)

        let postData = self.postArray[indexPath!.row]

        // update bookmark
        if let myid = Auth.auth().currentUser?.uid {
            // create updated data
            if postData.isBookMarked {
                let alert = UIAlertController(title: "ブックマークへの登録を解除しますか？", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "解除", style: .default, handler: { _ in
                    // If it has been already bookMarked, create updated data to remove myid to remove bookMark
                    let updateValue = FieldValue.arrayRemove([myid])
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
                    SVProgressHUD.showSuccess(withStatus: "登録解除")
                    SVProgressHUD.dismiss(withDelay: 1.0) {
                        postRef.updateData(["bookMarks": updateValue])
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                // If bookmark is pressed, create updated data to add myid
                let updateValue = FieldValue.arrayUnion([myid])
                // Write updated data to bookMarks
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

        // update likes
        if let myid = Auth.auth().currentUser?.uid {
            // create updated data
            var updateValue: FieldValue
            if postData.isLiked {
                // If you have already liked, create an update data to remove myid to remove liking
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // Create updated data to add myid if newly liked this time
                updateValue = FieldValue.arrayUnion([myid])
            }
            // write updated likes data to database
            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
            postRef.updateData(["likes": updateValue])
        }
    }

    @objc func tappedCopyButton(_: UIButton, forEvent event: UIEvent) {
//        make a copy of the posted contnet
        SVProgressHUD.show()
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
//        screen transition to CommentSectionViewController
        self.secondPagingViewController.segue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // performed when the screen transtion to OthersPrifileViewController was performed
        if segue.identifier == "ToOthersProfile" {
            let othersProfileViewController = segue.destination as! OthersProfileViewController
            othersProfileViewController.postData = sender as? PostData
        }
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
