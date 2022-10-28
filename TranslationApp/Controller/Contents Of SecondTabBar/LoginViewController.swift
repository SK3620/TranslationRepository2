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

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
            self.logoutButton.isEnabled = false
        } else {
            self.logoutButton.isEnabled = true
        }

        self.logoutButton.layer.borderWidth = 1
        self.logoutButton.layer.cornerRadius = 6
        self.logoutButton.layer.borderColor = UIColor.systemRed.cgColor

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
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
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
            SVProgressHUD.dismiss()
        }))
        present(alert, animated: true, completion: nil)
    }

//    戻るボタンで翻訳画面へ戻る
    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
