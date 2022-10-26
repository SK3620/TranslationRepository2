//
//  Edit1ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import RealmSwift
import SVProgressHUD
import UIKit

class EditStudyViewContoller: UIViewController, UITextViewDelegate {
    @IBOutlet var textView1: UITextView!
    @IBOutlet var textView2: UITextView!

    var inputDataTextView1: String = ""
    var resultDataTextView2: String = ""
    var translationId: Int = 0

    var realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView1.delegate = self
        self.textView2.delegate = self

        let textViewArr: [UITextView] = [textView1, textView2]
        self.setTextView(textViewArr: textViewArr)

        self.setDoneToolBar()
    }

    func setTextView(textViewArr: [UITextView]!) {
        textViewArr.forEach {
            $0.layer.borderColor = UIColor.systemGray.cgColor
            $0.layer.borderWidth = 2
        }
    }

    func setDoneToolBar() {
        // キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        let someArr = [textView1, textView2]
        for someNumber in someArr {
            someNumber!.inputAccessoryView = doneToolbar
        }
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.textView1.endEditing(true)
        self.textView2.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.textView1.text = self.inputDataTextView1
        self.textView2.text = self.resultDataTextView2
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)

        SVProgressHUD.show()
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationId)").first!

        try! self.realm.write {
            translationArr.inputData = textView1.text
            translationArr.resultData = textView2.text
            translationArr.inputAndResultData = textView1.text + textView2.text
            self.realm.add(translationArr, update: .modified)
        }

        SVProgressHUD.showSuccess(withStatus: "保存しました")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { () in
            SVProgressHUD.dismiss()
        }
    }
}
