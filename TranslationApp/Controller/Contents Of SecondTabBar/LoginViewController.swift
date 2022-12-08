//
//  LoginViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import Alamofire
import Firebase
import FirebaseAuth
import SVProgressHUD
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var mailAddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    @IBOutlet var view1: UIView!
    @IBOutlet var changePasswordButton: UIButton!

    var maxPasswordLength: Int = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view1.layer.cornerRadius = 10

        if Auth.auth().currentUser == nil {
            self.logoutButton.isEnabled = false
            self.deleteAccountButton.isEnabled = false
        } else {
            self.logoutButton.isEnabled = true
            self.deleteAccountButton.isEnabled = true
        }

        self.logoutButton.layer.borderWidth = 1
        self.logoutButton.layer.cornerRadius = 6
        self.logoutButton.layer.borderColor = UIColor.systemRed.cgColor
        self.deleteAccountButton.layer.borderWidth = 1
        self.deleteAccountButton.layer.cornerRadius = 6
        self.deleteAccountButton.layer.borderColor = UIColor.systemRed.cgColor

        //            textFieldとbuttonのデザインを設定
        let textFieldArr: [UITextField] = [mailAddressTextField, passwordTextField, displayNameTextField]
        let buttonArr: [UIButton] = [loginButton, createAccountButton]
        self.setTextFieldsAndButtons(textFieldArr: textFieldArr, buttonArr: buttonArr)
        self.setDoneToolBar(textFieldArr: textFieldArr)

        self.displayNameTextField.delegate = self
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        if Auth.auth().currentUser == nil {
            self.changePasswordButton.isEnabled = false
        } else {
            self.changePasswordButton.isEnabled = true
        }
    }

    func setTextFieldsAndButtons(textFieldArr: [UITextField]!, buttonArr: [UIButton]!) {
        textFieldArr.forEach {
            $0.layer.borderColor = UIColor.gray.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 6
        }
        buttonArr.forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemBlue.cgColor
            $0.layer.cornerRadius = 6
        }
    }

    func setDoneToolBar(textFieldArr: [UITextField]!) {
        // 決定バーの生成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        // インプットビュー設定
        textFieldArr.forEach {
            $0.inputAccessoryView = toolbar
        }
    }

    @objc func done() {
        self.mailAddressTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        self.displayNameTextField.endEditing(true)
    }

    func textFieldDidChangeSelection(_: UITextField) {
        guard let userName = displayNameTextField.text else { return }

        if userName.count > self.maxPasswordLength {
            self.displayNameTextField.text = String(userName.prefix(self.maxPasswordLength))
        }
    }

    //    アカウント作成ボタン
    @IBAction func createAccountButton(_: Any) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = displayNameTextField.text {
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("何かが入力されていません")
                SVProgressHUD.showError(withStatus: "必要項目を入力してください")
                SVProgressHUD.dismiss(withDelay: 1.5)
                return
            }

            SVProgressHUD.show()

            //            アドレスとパスワードでユーザー作成　ユーザー作成に成功すると、自動でログインする
            Auth.auth().createUser(withEmail: address, password: password) { _, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました")
                    return
                }

                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました")
                            return
                        }

                        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument")
                        let postDic = [
                            "age": "ー",
                            "work": "ー",
                            "gender": "ー",
                            "introduction": "ー",
                            "academicHistory": "ー",
                            "hobby": "ー",
                            "visitedCountry": "ー",
                            "wannaVisitCountry": "ー",
                            "whereYouLive": "ー",
                            "birthday": "ー",
                            "etc": "ー",
                        ] as [String: Any]
                        print(postDic)
                        postRef.setData(postDic, merge: true)
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                        SVProgressHUD.dismiss()

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    //    ログインボタン
    @IBAction func loginButton(_: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力してください")
                return
            }

            SVProgressHUD.show()

            Auth.auth().signIn(withEmail: address, password: password) { _, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                SVProgressHUD.dismiss()
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

//    ログアウトボタン
    @IBAction func logoutButton(_: Any) {
        let alert = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "ログアウト", style: .default, handler: { _ in
            SVProgressHUD.show()
//            ログアウト処理
            try! Auth.auth().signOut()
            SVProgressHUD.showSuccess(withStatus: "ログアウトが完了しました")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func deleteAccountButton(_: Any) {
        let user = Auth.auth().currentUser!
        let alert = UIAlertController(title: "アカウントを削除する", message: "アカウントを削除した場合、'\(user.displayName!)'さんのすべての投稿やコメントなどが削除されます", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))

        alert.addTextField { mailAddressTextField in
            //            configurationHandler
            //            A block for configuring the text field prior to displaying the alert
            mailAddressTextField.placeholder = "メールアドレス"
            mailAddressTextField.textAlignment = .center
            mailAddressTextField.delegate = self
        }

        alert.addTextField { passwordTextField in
            passwordTextField.placeholder = "パスワード(6文字以上)"
            passwordTextField.textAlignment = .center
            passwordTextField.delegate = self
        }

        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            SVProgressHUD.show()
            if let mailAddress = alert.textFields?.first?.text, let password = alert.textFields?.last?.text {
                Auth.auth().signIn(withEmail: mailAddress, password: password) { _, error in
                    if let error = error {
                        print("アカウント削除のためのログイン失敗\(error)")
                        SVProgressHUD.showError(withStatus: "アカウントの削除に失敗しました")
                        SVProgressHUD.dismiss(withDelay: 1.5)
                        return
                    } else {
                        print("アカウント削除のためのログイン成功")
                        //                        ログインが成功したら、次にアカウント削除処理を実行
                        let user = Auth.auth().currentUser
                        self.excuteMultipleAsyncProcesses(user: user!) { error in
                            if let error = error {
                                print("completionにて、非同期処理過程でエラーが起こりました\(error)")
                            } else {
                                print("completionにて、非同期処理の削除が成功しました")
                            }
                        }
                    }
                }
            } else {
                print("アカウント削除のためのログイン失敗")
                SVProgressHUD.showError(withStatus: "アカウントの削除に失敗しました")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    func excuteMultipleAsyncProcesses(user: User, completion: @escaping (Error?) -> Void) {
//        documentIdを格納する配列
        var documentIdArray: [String] = []
        // 非同期のグループ作成
        let dispatchGroup = DispatchGroup()
        // 並列で実行する.concurrent
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)

        //        一つ目の処理はprofileDataの削除
        dispatchGroup.enter()
        dispatchQueue.async {
            Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument").delete { error in
                guard error == nil else { completion(error)
//                    ここでクロージャを呼んでいる。
                    print("ProfileDataの削除失敗 leave()\(error!)")
                    dispatchGroup.leave()
                    return
                }
                print("ProfileDataの削除成功 leave()")
                completion(nil)
                dispatchGroup.leave()
            }
        }

//        二つ目は"comments"内のコメントデータドキュメントの削除
        dispatchGroup.enter()
        dispatchQueue.async {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: user.uid)
            commentsRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("”comments”内のコメントデータドキュメントの取得に失敗しました、leave()を実行します。エラー内容は\(error)")
                    dispatchGroup.leave()
                    return
                }
                if let querySnapshot = querySnapshot {
                    if querySnapshot.isEmpty {
                        print("”comments”内のコメントデータドキュメントが空でした　leave()を実行します")
                        dispatchGroup.leave()
                        return
                    }
                    print("”comments”内のコメントデータドキュメントの取得に成功しました")
                    var countedQuerySnapshot: Int = querySnapshot.documents.count
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        queryDocumentSnapshot.reference.delete { error in
                            if let error = error {
                                print("”comments”内のコメントデータドキュメントの削除に失敗しました\(error)")
                                return
                            } else {
                                print("”comments”内のコメントデータドキュメントの削除に成功しました leave()を実行します")
                                countedQuerySnapshot = countedQuerySnapshot - 1
                                if countedQuerySnapshot == 0 {
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
            }
        }

//        三つ目の処理は投稿データの削除
        dispatchGroup.enter()
        dispatchQueue.async {
            let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid)
            postsRef.getDocuments { querySnapshot, error in
                guard error == nil else { completion(error)
                    print("投稿データの取得失敗 leave()\(error!)")
                    dispatchGroup.leave()
                    return
                }
                print("投稿データの取得成功")
//                ここの処理はもしかたら、isEmptyを使うべきか？
                if let querySnapshot = querySnapshot {
                    if querySnapshot.isEmpty {
                        print("取得した投稿データがisEmptyでした leave()")
                        dispatchGroup.leave()
                        return
                    }
                    print("取得した投稿データがisEmptyではなかったため、以下の処理を実行します。")
//                    取得したドキュメントの数を格納する定数
                    var countedQuerySnapshot: Int = querySnapshot.documents.count
                    querySnapshot.documents.forEach { queryDocumentSnapshot in
                        queryDocumentSnapshot.reference.delete { error in
                            let documentId: String = PostData(document: queryDocumentSnapshot).documentId
                            documentIdArray.append(documentId)
                            if let error = error {
                                print("ドキュメントの削除失敗 leave()\(error)")
                                completion(error)
                                dispatchGroup.leave()
                                return
                            } else {
                                print("ドキュメントの削除成功 leave()")
                                completion(nil)

//                                dispatchGroup.leave()は全ての（最後の）ドキュメント削除時に実行させる
                                //    querySnapshot.documets.countでforEachされるたびにcountから-1して、if文でleave()を実行させる
                                countedQuerySnapshot = countedQuerySnapshot - 1
                                print("ドキュメント数\(countedQuerySnapshot)")
                                if countedQuerySnapshot == 0 {
//                                    これで、forEachによって、dispatchGroup.leave()が何回も呼ばれることはない
                                    print("ドキュメント数が0だったため、commentDataDocumentを削除する処理が実行されました")
                                    self.deleteCommentDataDocumentInPosts(documentIdArray: documentIdArray)
                                    print("leave()")
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
            }
        }

//        dispatchGroup.enter()
//        dispatchQueue.async {
//            guard documentIdArray.isEmpty else {
//                print("documentIdArrayが空でした。leave()してretrun")
//                dispatchGroup.leave()
//                return
//            }
//            var commentDataDocumentArr: [
//            for documentId in documentIdArray {
//                let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(documentId).collection("commentDataCollection")
//                commentsRef.getDocuments { querySnapshot, error in
//                    guard error == nil else {
//                        print("コメントデータドキュメントの取得失敗\(error!)")
//                        return
//                    }
//                    print("コメントデータドキュメントの取得成功")
//                    if let querySnapshot = querySnapshot {
//                        if querySnapshot.isEmpty {
//                            print("取得したコメントデータドキュメントがisEmptyだったためreturnします")
//                            return
//                        }
//                        var countedQuerySnapshot: Int = querySnapshot.documents.count
//                        querySnapshot.documents.forEach { queryDocumentSnapahot in
//                            queryDocumentSnapahot.reference.delete { error in
//                                if let error = error {
//                                    print("コメントデータのドキュメント削除失敗\(error)")
//                                } else {
//                                    print("コメントデータのドキュメント削除成功")
//    //                                dispatch.leave()は最後のコメントデータドキュメントが削除された時に実行させる
//                                    countedQuerySnapshot = countedQuerySnapshot - 1
//                                    if countedQuerySnapshot == 0 {
//                                        dispatchGroup.leave()
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }

//        プロフィール画像の削除処理
        dispatchGroup.enter()
        dispatchQueue.async {
            let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")
            imageRef.delete { error in
                if let error = error {
                    print("画像の削除に失敗しました leave()\(error)")
                    completion(error)
                    dispatchGroup.leave()
                    return
                } else {
                    print("画像の削除に成功しました leave()")
                    completion(nil)
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("アカウント削除処理以外の非同期処理が終了しました 次にアカウント削除処理を実行します")
            user.delete { error in
                if let error = error {
                    print("アカウント削除失敗\(error)")
                    SVProgressHUD.showError(withStatus: "アカウント削除に失敗しました\n再度ログインし、アカウントを削除してください")
                    SVProgressHUD.dismiss(withDelay: 2.5)
                    return
                } else {
                    print("アカウント削除成功")
                    SVProgressHUD.showSuccess(withStatus: "アカウント削除に成功しました")
                    SVProgressHUD.dismiss(withDelay: 1.5) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }

    func deleteCommentDataDocumentInPosts(documentIdArray: [String]) {
        for documentId in documentIdArray {
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(documentId).collection("commentDataCollection")
            commentsRef.getDocuments { querySnapshot, error in
                guard error == nil else {
                    print("コメントデータドキュメントの取得失敗\(error!)")
                    return
                }
                print("コメントデータドキュメントの取得成功")
                if let querySnapshot = querySnapshot {
                    if querySnapshot.isEmpty {
                        print("取得したコメントデータドキュメントがisEmptyだったためreturnします")
                        return
                    }
                    var countedQuerySnapshot: Int = querySnapshot.documents.count
                    querySnapshot.documents.forEach { queryDocumentSnapahot in
                        queryDocumentSnapahot.reference.delete { error in
                            if let error = error {
                                print("コメントデータのドキュメント削除失敗\(error)")
                                return
                            } else {
                                print("コメントデータのドキュメント削除成功")
//                                dispatch.leave()は最後のコメントデータドキュメントが削除された時に実行させる
                                countedQuerySnapshot = countedQuerySnapshot - 1
                                if countedQuerySnapshot == 0 {}
                            }
                        }
                    }
                }
            }
        }
    }

//    @IBAction func deleteButton(_: Any) {
//        let alert = UIAlertController(title: "アカウントを削除する", message: "アカウントを削除した場合、全ての投稿データも削除されます。", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "削除する", style: .default, handler: { _ in
//            SVProgressHUD.show()
//            let user = Auth.auth().currentUser!
//            self.deleteProfileData(user: user)
//        }))
//        present(alert, animated: true, completion: nil)
//    }

//    プロフィールデータドキュメントの削除
//    func deleteProfileData(user: User) {
//        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument")
//        postRef.delete { error in
//            if let error = error {
//                print("profileDataの削除失敗\(error)")
//            } else {
//                print("profileDataの削除成功")
//                self.deleteDocumentData(user: user)
//            }
//        }
//    }
//
    ////    投稿データドキュメントの削除
//    func deleteDocumentData(user: User) {
//        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid)
//        postRef.getDocuments { querySnapshot, error in
//            if let error = error {
//                print("削除するドキュメントの取得失敗\(error)")
//            }
//            if let querySnapshot = querySnapshot {
//                if querySnapshot.isEmpty {
//                    self.deleteProfileImage(user: user)
//                    return
//                }
//                print("削除するドキュメントの取得成功")
//                querySnapshot.documents.forEach { queryDocumentSnapshot in
//                    queryDocumentSnapshot.reference.delete { error in
//                        let documentId: String = PostData(document: queryDocumentSnapshot).documentId
//                        if let error = error {
//                            print("ドキュメントの削除失敗\(error)")
//                        } else {
//                            print("ドキュメントの削除成功")
//                            self.deleteCommentData(documentId: documentId, user: user)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
    ////    コメントデータドキュメントの削除
//    func deleteCommentData(documentId: String?, user: User) {
//        if let documentId = documentId {
//            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(documentId).collection("commentDataCollection")
//            commentsRef.getDocuments { querySnapshot, error in
//                if let error = error {
//                    print("commentDataCollectionのドキュメント取得失敗\(error)")
//                }
//                if let querySnapshot = querySnapshot {
//                    if querySnapshot.isEmpty {
//                        self.deleteProfileImage(user: user)
//                        return
//                    }
//                    print("commentDataCollectionのドキュメント取得成功")
//                    querySnapshot.documents.forEach { queryDocumentSnapahot in
//                        queryDocumentSnapahot.reference.delete { error in
//                            if let error = error {
//                                print("commentDataCollectionのドキュメント削除失敗\(error)")
//                            } else {
//                                print("commentDataCollectionのドキュメント削除成功")
//                                print("実行1")
//                            }
//                            print("実行2")
//                        }
//                        print("実行3")
//                    }
//                    self.deleteProfileImage(user: user)
//                    print("実行4")
//                }
//            }
//        }
//    }
//
    ////    プロフィール画像の削除
//    func deleteProfileImage(user: User) {
//        let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg")
//        print("imageRefの値確認\(imageRef)")
//        imageRef.delete { error in
//            if let error = error {
//                print("画像の削除失敗\(error)")
//                self.deleteAccount()
//            } else {
//                print("画像の削除成功")
//                self.deleteAccount()
//            }
//        }
//    }
//
    ////    アカウント削除
//    func deleteAccount() {
//        if let user = Auth.auth().currentUser {
//            user.delete { error in
//                if let error = error {
//                    print("アカウント削除失敗\(error)")
//                    SVProgressHUD.showError(withStatus: "アカウント削除に失敗しました\n再度ログインし、アカウントを削除してください")
//                    SVProgressHUD.dismiss(withDelay: 2.5)
//                    return
//                } else {
//                    print("アカウント削除成功")
//                    SVProgressHUD.showSuccess(withStatus: "アカウント削除に成功しました")
//                    SVProgressHUD.dismiss(withDelay: 1.5) {
//                        self.dismiss(animated: true)
//                    }
//                }
//            }
//        }
//    }

    @IBAction func changePasswordButton(_: Any) {
        self.passwordResetting()
    }

    func passwordResetting() {
        let user = Auth.auth().currentUser!
        Auth.auth().languageCode = "ja_JP" // 日本語に変換
        guard let email = user.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { err in
            if let err = err {
                print("再設定メールの送信に失敗しました。\(err)")
                return
            }
            print("再設定メールの送信に成功しました。")
            self.setAlert()
        }
    }

    func setAlert() {
        let user = Auth.auth().currentUser!
        let alert = UIAlertController(title: "パスワード変更", message: "\(user.email!)へパスワード変更用のメールを送信しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

//    戻るボタンで翻訳画面へ戻る
    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
