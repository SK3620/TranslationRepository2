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

        WritingData.determinationOfIsProfileImageExisted { valueForIsProfileImageExisted in
            self.valueForIsProfileImageExisted = valueForIsProfileImageExisted
        }
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

        BlockUnblock.determineIfYouAreBeingBlocked { result in
            switch result {
            case let .failure(error):
                print("データの取得に失敗しました\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
            case let .success(blockedBy):
                WritingData.writePostData(blockedBy: blockedBy, text: self.textView.text!, valueForIsProfileImageExisted: self.valueForIsProfileImageExisted!, array: self.array) {
                    self.secondPagingViewController.savedTextView_text = ""
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
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
