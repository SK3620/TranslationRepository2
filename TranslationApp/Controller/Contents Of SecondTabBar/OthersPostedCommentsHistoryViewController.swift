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

        SVProgressHUD.show(withStatus: "データ取得中")
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
        cell.bubbleButton.isEnabled = false
        cell.bubbleButton.isHidden = true
        cell.commentButton.isEnabled = false
        cell.commentButton.isHidden = true
        cell.bubbleLabel.isHidden = true

        return cell
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
