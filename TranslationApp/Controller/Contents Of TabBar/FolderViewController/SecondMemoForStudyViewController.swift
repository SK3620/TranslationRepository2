//
//  SecondMemoForStudyViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/14.
//

import RealmSwift
import SVProgressHUD
import UIKit

class SecondMemoForStudyViewController: UIViewController {
    @IBOutlet private var memoTextView: UITextView!

    internal var translationId: Int!
    internal var memo: String = ""

    private var realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.memoTextView.text = self.memo
        self.setDoneToolBar()
        // Do any additional setup after loading the view.
    }

    private func setDoneToolBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped(_:)))
        doneToolbar.items = [spacer, doneButton]
        self.memoTextView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTapped(_: UIButton) {
        self.memoTextView.endEditing(true)
    }

    @IBAction func saveButton(_: Any) {
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationId!)").first!
        try! self.realm.write {
            translationArr.secondMemo = self.memoTextView.text
            self.realm.add(translationArr, update: .modified)
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.dismiss(animated: true)
        }
    }

    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true)
    }
}
