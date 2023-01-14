//
//  PostViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Alamofire
import Firebase
import SVProgressHUD
import UIKit

class PostViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var textView: UITextView!

    @IBOutlet private var label1: UILabel!

    @IBOutlet private var correctButton: UIButton!
    @IBOutlet private var HowToLearnButton: UIButton!
    @IBOutlet private var wordButton: UIButton!
    @IBOutlet private var grammerButton: UIButton!
    @IBOutlet private var conversationButton: UIButton!
    @IBOutlet private var listeningButton: UIButton!
    @IBOutlet private var pronunciationButton: UIButton!
    @IBOutlet private var certificationButton: UIButton!
    @IBOutlet private var etcButton: UIButton!

    @IBOutlet private var postButton: UIBarButtonItem!
    @IBOutlet private var backBarButtonItem: UIBarButtonItem!

    var secondPagingViewController: SecondPagingViewController!
    var savedTextView_text: String = ""

    var valueForIsProfileImageExisted: String?

    private var array: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.postButton.isEnabled = true

        self.label1.text = "下の項目から関連のあるトピックを追加できます"
        self.title = "投稿"

        self.textView.text = self.savedTextView_text
        self.textView.delegate = self
        self.textView.endEditing(false)

        self.settingsForNavigationBarAppearence()

        self.setButtonDesign(buttonArr: [self.correctButton, self.HowToLearnButton, self.wordButton, self.grammerButton, self.conversationButton, self.listeningButton, self.pronunciationButton, self.certificationButton, self.etcButton])

        self.setDoneToolBar()

        self.determinationOfIsProfileImageExisted()
    }

    private func settingsForNavigationBarAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
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

    private func setButtonDesign(buttonArr: [UIButton]) {
        buttonArr.forEach {
            $0.backgroundColor = .white
            $0.layer.borderWidth = 1.5
            $0.layer.cornerRadius = 6
            $0.layer.borderColor = UIColor.systemGray2.cgColor
        }
    }

    private func determinationOfIsProfileImageExisted() {
        let user = Auth.auth().currentUser!
        let profileImagesRef = Firestore.firestore().collection(FireBaseRelatedPath.imagePathForDB).document("\(user.uid)'sProfileImage")
        profileImagesRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("エラー　\(error)")
            }
            if let documentSnapshot = documentSnapshot, let imagesDic = documentSnapshot.data() {
                let isProfileImageExisted = imagesDic["isProfileImageExisted"] as? String
                if isProfileImageExisted != "nil" {
                    self.valueForIsProfileImageExisted = isProfileImageExisted!
                } else {
                    self.valueForIsProfileImageExisted = "nil"
                }
            } else {
                self.valueForIsProfileImageExisted = "nil"
            }
        }
    }

    func textViewDidChange(_: UITextView) {
        if self.textView.text == "" {
            self.label1.text = "下の項目から関連のあるトピックを追加できます"
        } else {
            self.label1.text = ""
        }
    }

    //    post button
    @IBAction func postButton(_: Any) {
        SVProgressHUD.show()
        if self.textView.text.isEmpty {
            SVProgressHUD.showError(withStatus: "投稿内容を入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            self.postButton.isEnabled = true
            self.backBarButtonItem.isEnabled = true
            return
        }
        self.postButton.isEnabled = false
        self.backBarButtonItem.isEnabled = false

        let user = Auth.auth().currentUser!
        let nGram = self.nGram(input: self.textView.text, n: 2)
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document()
        let postDic = [
            "contentOfPost": self.textView.text!,
            "postedDate": FieldValue.serverTimestamp(),
            "userName": user.displayName!,
            "uid": user.uid,
            "numberOfComments": "0",
            "isProfileImageExisted": self.valueForIsProfileImageExisted!,
            "nGram": nGram,
        ] as [String: Any]
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            postRef.setData(postDic) { error in
                if let error = error {
                    print("エラーでした\(error)")
                    return
                }
                let value = FieldValue.arrayUnion(self.array)
                postRef.updateData(["topic": value])
                self.secondPagingViewController.savedTextView_text = ""
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func nGram(input: String, n: Int) -> [String] {
        // nの数が文字列の文字数より多くなってしまうとエラーになるためreturnさせる
        guard input.count >= n else {
            print("nにはinputの文字数以下の整数値を入れてください")
            return []
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

    @IBAction func backButton(_: Any) {
        if self.textView.text.isEmpty != true {
            let alert = UIAlertController(title: "この編集を保存しますか？", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { _ in
                self.secondPagingViewController.savedTextView_text = ""
                self.dismiss(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
                self.secondPagingViewController.savedTextView_text = self.textView.text
                self.dismiss(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true)
        }
    }

    @IBAction func correctButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.correctButton)
    }

    @IBAction func howToLearnButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.HowToLearnButton)
    }

    @IBAction func wordButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.wordButton)
    }

    @IBAction func grammerButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.grammerButton)
    }

    @IBAction func conversationButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.conversationButton)
    }

    @IBAction func listeningButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.listeningButton)
    }

    @IBAction func pronunciationButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.pronunciationButton)
    }

    @IBAction func certificationButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.certificationButton)
    }

    @IBAction func etcButton(_: Any) {
        self.determineIfButtonIsTapped(button: self.etcButton)
    }

    private func determineIfButtonIsTapped(button: UIButton) {
        if button.backgroundColor == .white {
            // state that the button is recognized as being pressed.
            button.backgroundColor = .systemCyan
            button.tintColor = .white
            button.layer.borderWidth = 1.5
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.systemCyan.cgColor
            self.array.append(button.titleLabel!.text!)
        } else {
            // state that the button is recognized as being pressed.
            button.backgroundColor = .white
            button.tintColor = .systemGray2
            button.layer.borderWidth = 1.5
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.systemGray2.cgColor
            self.array.removeAll(where: { $0 == button.titleLabel!.text! })
        }
    }
}
