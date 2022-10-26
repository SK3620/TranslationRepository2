//
//  Memo2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/19.
//

import RealmSwift
import UIKit

class QuickMemoViewContoller: UIViewController, UITextViewDelegate {
    @IBOutlet var textView: UITextView!

    let realm = try! Realm()
    let firstMemoArr = try! Realm().objects(FirstMemo.self)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.delegate = self

//        キーボードに完了バーを設定
        self.setDoneToolBar()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        if self.firstMemoArr.count != 0 {
            self.textView.text = self.firstMemoArr[0].memo
        }
    }

    func setDoneToolBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.textView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.textView.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func textViewDidChange(_: UITextView) {
        let firstMemo = FirstMemo()
        do {
            let realm = try Realm()
            try realm.write {
                firstMemo.memo = self.textView.text
                realm.add(firstMemo, update: .modified)
            }
        } catch {
            print("エラー")
        }
    }
}
