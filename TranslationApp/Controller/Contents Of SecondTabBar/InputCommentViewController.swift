//
//  InputCommentViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/04.
//

import Firebase
import SVProgressHUD
import UIKit

class InputCommentViewController: UIViewController {
    @IBOutlet var textView: UITextView!

    @IBOutlet private var postCommentButton: UIBarButtonItem!
    @IBOutlet private var backBarButtonItem: UIBarButtonItem!

    // Single document of the tapped cell in the timeline screen
    var postData: PostData!
    var secondPostArray: [SecondPostData] = []

    private var listener: ListenerRegistration!

    var commentSectionViewController: CommentSectionViewController!
    var commentsHistoryViewController: CommentsHistoryViewController!
    var bookMarkCommentsSectionViewController: BookMarkCommentsSectionViewController?
    var othersCommentsHistoryViewController: OthersCommentsHistoryViewController?

    var valueForIsProfileImageExisted: String?

    var textView_text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        guard Auth.auth().currentUser != nil else {
            self.dismiss(animated: true)
            return
        }
        self.settingsForNavigationBarAppearence()

        self.setDoneToolBar()

        self.textView.endEditing(false)

        WritingData.determinationOfIsProfileImageExisted { valueForIsProfileImageExisted in
            self.valueForIsProfileImageExisted = valueForIsProfileImageExisted
        }

        self.textView.text = self.textView_text

        self.postCommentButton.isEnabled = true
    }

    private func setDoneToolBar() {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        self.textView.inputAccessoryView = toolbar
    }

    @objc func done() {
        self.textView.endEditing(true)
    }

    private func settingsForNavigationBarAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.listener?.remove()

        // called when the screen transition from commentSectionVC
        if let textView_text = self.textView.text, let commentSectionViewController = self.commentSectionViewController {
            commentSectionViewController.comment = textView_text
        }

        // called when the screen transition from commentsHistroyViewController
        if let textView_text = self.textView.text, let commentsHistroyViewController = self.commentsHistoryViewController {
            commentsHistroyViewController.comment = textView_text
        }

        // called when the screen transition from bookMarkCommentsSectionViewController
        if let textView_text = self.textView.text, let bookMarkCommentsSectionViewController = self.bookMarkCommentsSectionViewController {
            bookMarkCommentsSectionViewController.comment = textView_text
        }

        // called when the screen transition from othersCommentsHistoryViewController
        if let textView_text = self.textView.text, let othersCommentsHistoryViewController = self.othersCommentsHistoryViewController {
            othersCommentsHistoryViewController.comment = textView_text
        }
    }

    @IBAction func backButton(_: Any) {
        self.textView.endEditing(true)
        dismiss(animated: true)
    }

    // post comment button
    @IBAction func postCommentButton(_: Any) {
        SVProgressHUD.show()
        let user = Auth.auth().currentUser
        let textView_text = self.textView.text

        self.postCommentButton.isEnabled = false
        self.backBarButtonItem.isEnabled = false

        guard user != nil, textView_text!.isEmpty != true else {
            SVProgressHUD.showError(withStatus: "コメントを入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.postCommentButton.isEnabled = true
            self.backBarButtonItem.isEnabled = true
            return
        }

        BlockUnblock.determineIfYouAreBeingBlocked { result in
            switch result {
            case let .failure(error):
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                print("データの取得に失敗しました\(error.localizedDescription)")
            case let .success(blockedBy):
                let today: String = self.getToday()
                WritingData.writeCommentData(postData: self.postData, blockedBy: blockedBy, text: textView_text!, today: today, valueForIsProfileImageExisted: self.valueForIsProfileImageExisted!) {
                    self.excuteMultipleAsyncProcesses(textView_text: textView_text!, today: today)
                }
            }
        }
    }

    func getToday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))
        let today = dateFormatter.string(from: date)
        return today
    }

    // update the number of comments
    func excuteMultipleAsyncProcesses(textView_text _: String, today _: String) {
        print("複数の非同期処理を実行します")
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")

        // update the number of comments
        dispatchGroup.enter()
        dispatchQueue.async {
            if Auth.auth().currentUser != nil {
                let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
                let numberOfComments = String(self.secondPostArray.count)
                let postDic = [
                    "numberOfComments": numberOfComments,
                ]
                postRef.setData(postDic, merge: true) { error in
                    if let error = error {
                        print("エラーでした\(error)")
                    } else {
                        dispatchGroup.leave()
                        print("二つ目のleave()を実行しました")
                    }
                }
            }
        }

        //
        dispatchGroup.enter()
        dispatchQueue.async {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: self.postData.documentId).order(by: "commentedDate", descending: true)
            commentsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("エラーでした、commentsコレクション内のドキュメントの取得に失敗しました\(error)")
                }
                if let querySnapshot = querySnapshot {
                    var excuteLeaveAtTheEnd: Int = querySnapshot.documents.count
                    print("commentsコレクション内のドキュメントの取得に成功しました")
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        self.secondPostArray.append(SecondPostData(document: queryDocumentSnapshot))
                        excuteLeaveAtTheEnd = excuteLeaveAtTheEnd - 1
                        if excuteLeaveAtTheEnd == 0 {
                            let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(self.postData.documentId)
                            let numberOfComments = String(self.secondPostArray.count)
                            print("self.secondPostArray.count：\(self.secondPostArray.count)")
                            let postDic = [
                                "numberOfComments": numberOfComments,
                            ]
                            postRef.setData(postDic, merge: true) { error in
                                if let error = error {
                                    print("エラーでした\(error)")
                                } else {
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("非同期処理完了")

//            if let commentSectionViewController = self.commentSectionViewController { commentSectionViewController.secondPostArray = self.secondPostArray
//                commentSectionViewController.reloadTableView()
//            }
//            if let commentsHistroyViewController = self.commentsHistoryViewController {
//                commentsHistroyViewController.secondPostArray = self.secondPostArray
//                commentsHistroyViewController.reloadTableView()
//            }

//            if let bookMarkCommentsSectionViewController = self.bookMarkCommentsSectionViewController {
//                bookMarkCommentsSectionViewController.secondPostArray = self.secondPostArray
//                bookMarkCommentsSectionViewController.reloadTableView()
//            }

//            if let othersCommentsHistoryViewController = self.othersCommentsHistoryViewController {
//                othersCommentsHistoryViewController.secondPostArray = self.secondPostArray
//                othersCommentsHistoryViewController.reloadTableView()
//            }
            SVProgressHUD.showSuccess(withStatus: "コメントしました")
            SVProgressHUD.dismiss(withDelay: 1.5) {
                self.textView.text = ""
                self.textView.endEditing(true)
                self.dismiss(animated: true, completion: nil)
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
}
