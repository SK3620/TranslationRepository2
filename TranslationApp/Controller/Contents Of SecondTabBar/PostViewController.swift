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
    @IBOutlet var label1: UILabel!

    @IBOutlet var correctButton: UIButton!
    @IBOutlet var HowToLearnButton: UIButton!
    @IBOutlet var wordButton: UIButton!
    @IBOutlet var grammerButton: UIButton!
    @IBOutlet var conversationButton: UIButton!
    @IBOutlet var listeningButton: UIButton!
    @IBOutlet var pronunciationButton: UIButton!
    @IBOutlet var certificationButton: UIButton!
    @IBOutlet var etcButton: UIButton!

    var secondPagingViewController: SecondPagingViewController!
    var savedTextView_text: String = ""

    var array: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label1.text = "下の項目から関連のあるトピックを追加できます"
        self.textView.text = self.savedTextView_text

        self.setButtonDesign(buttonArr: [self.correctButton, self.HowToLearnButton, self.wordButton, self.grammerButton, self.conversationButton, self.listeningButton, self.pronunciationButton, self.certificationButton, self.etcButton])

        self.textView.delegate = self

        self.title = "投稿"
        self.textView.endEditing(false)
        // 決定バーの生成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        // インプットビュー設定
        self.textView.inputAccessoryView = toolbar
        // Do any additional setup after loading the view.
    }

    @objc func done() {
        self.textView.endEditing(true)
    }

    func setButtonDesign(buttonArr: [UIButton]) {
        buttonArr.forEach {
            $0.backgroundColor = .white
            $0.layer.borderWidth = 1.5
            $0.layer.cornerRadius = 6
            $0.layer.borderColor = UIColor.systemGray2.cgColor
        }
    }

    func textViewDidChange(_: UITextView) {
        if self.textView.text == "" {
            self.label1.text = "下の項目から関連のあるトピックを追加できます"
        } else {
            self.label1.text = ""
        }
    }

    //    投稿ボタン
    @IBAction func postButton(_: Any) {
        SVProgressHUD.show()
        if self.textView.text.isEmpty {
            SVProgressHUD.showError(withStatus: "投稿内容を入力してください")
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        }

        let user = Auth.auth().currentUser!
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document()
        let postDic = [
            "contentOfPost": self.textView.text!,
            "postedDate": FieldValue.serverTimestamp(),
            "userName": user.displayName!,
            "uid": user.uid,
        ] as [String: Any]
        postRef.setData(postDic)

        let value = FieldValue.arrayUnion(self.array)
        postRef.updateData(["topic": value])

        self.secondPagingViewController.savedTextView_text = ""
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        SVProgressHUD.dismiss(withDelay: 1.5, completion: { () in
            self.dismiss(animated: true)
        })
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
        ButtonModel(button: self.correctButton, postViewController: self)
    }

    @IBAction func howToLearnButton(_: Any) {
        ButtonModel(button: self.HowToLearnButton, postViewController: self)
    }

    @IBAction func wordButton(_: Any) {
        ButtonModel(button: self.wordButton, postViewController: self)
    }

    @IBAction func grammerButton(_: Any) {
        ButtonModel(button: self.grammerButton, postViewController: self)
    }

    @IBAction func conversationButton(_: Any) {
        ButtonModel(button: self.conversationButton, postViewController: self)
    }

    @IBAction func listeningButton(_: Any) {
        ButtonModel(button: self.listeningButton, postViewController: self)
    }

    @IBAction func pronunciationButton(_: Any) {
        ButtonModel(button: self.pronunciationButton, postViewController: self)
    }

    @IBAction func certificationButton(_: Any) {
        ButtonModel(button: self.certificationButton, postViewController: self)
    }

    @IBAction func etcButton(_: Any) {
        ButtonModel(button: self.etcButton, postViewController: self)
    }
}
