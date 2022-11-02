//
//  LoginViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import Alamofire
import Firebase
import SVProgressHUD
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var mailAddressTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    @IBOutlet var view1: UIView!

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

    //    アカウント作成ボタン
    @IBAction func createAccountButton(_: Any) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = displayNameTextField.text {
            if address.isEmpty || password.isEmpty || displayName.isEmpty || displayName == "ー" {
                print("何かが入力されていません")
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

//    アカウント削除ボタン
    @IBAction func deleteAccountButton(_: Any) {
        let alert = UIAlertController(title: "アカウント削除", message: "アカウントを削除しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .default, handler: { _ in
            SVProgressHUD.show()
//            削除処理
            let user = Auth.auth().currentUser!
            user.delete { error in
                if let error = error {
                    // An error happened.
                    print("削除失敗\(error)")
                } else {
                    // Account deleted.
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument")
                    postRef.delete(completion: { error in
                        if let error = error {
                            print("profileDataの削除失敗\(error)")
                        } else {
                            print("profileDataの削除成功")
                        }
                    })

                    Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(user.uid)" + ".jpg").delete(completion: { error in
                        if let error = error {
                            print("画像削除失敗\(error)")
                        } else {
                            print("画像削除成功")
                        }
                    })
                }
            }
            SVProgressHUD.showSuccess(withStatus: "アカウント削除が完了しました")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
//                self.profileViewController.setImageFromStorage()
            }
        }))
        present(alert, animated: true, completion: nil)
    }

//    戻るボタンで翻訳画面へ戻る
    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
