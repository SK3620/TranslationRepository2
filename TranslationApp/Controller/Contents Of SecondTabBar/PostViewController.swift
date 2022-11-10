//
//  PostViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

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

    var array: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label1.text = "下の項目から関連のあるトピックを追加できます"

        self.setButtonDesign(buttonArr: [self.correctButton, self.HowToLearnButton, self.wordButton, self.grammerButton, self.conversationButton, self.listeningButton, self.pronunciationButton, self.certificationButton, self.etcButton])

        self.textView.delegate = self

        self.title = "タイムライン"
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
            self.label1.text == ""
        }
    }

    //    投稿ボタン
    @IBAction func postButton(_: Any) {
        SVProgressHUD.show()
        if self.textView.text.isEmpty {
            SVProgressHUD.showError(withStatus: "投稿内容を入力してください")
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

        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        self.dismiss(animated: true)
    }

    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true)
        print(self.array)
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
