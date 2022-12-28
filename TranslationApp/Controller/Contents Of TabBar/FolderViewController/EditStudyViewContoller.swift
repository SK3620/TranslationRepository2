//
//  Edit1ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import Alamofire
import RealmSwift
import SVProgressHUD
import UIKit

class EditStudyViewContoller: UIViewController, UITextViewDelegate {
    @IBOutlet var textView1: UITextView!
    @IBOutlet var textView2: UITextView!

    var inputDataTextView1: String = ""
    var resultDataTextView2: String = ""
    
    var translationId: Int = 0

    private var realm = try! Realm()
    private var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

//       notification center to raise the view by the height of the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.textView1.delegate = self
        self.textView2.delegate = self

        let textViewArr: [UITextView] = [textView1, textView2]
        self.setTextView(textViewArr: textViewArr)

        self.setDoneToolBar()
        self.setBarButtonItem()
    }
    
    override func viewWillAppear(_: Bool) {
           super.viewWillAppear(true)

           self.textView1.text = self.inputDataTextView1
           self.textView2.text = self.resultDataTextView2
       }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if !self.textView2.isFirstResponder {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }

    func setTextView(textViewArr: [UITextView]!) {
        textViewArr.forEach {
            $0.layer.borderColor = UIColor.systemGray3.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 6
        }
    }

    func setDoneToolBar() {
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

    func setBarButtonItem() {
        let rightBarButtonItem = UIBarButtonItem(title: "保存する", style: .done, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
    }

//   a button to save
    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        SVProgressHUD.show()
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationId)").first!
        try! self.realm.write {
            translationArr.inputData = textView1.text
            translationArr.resultData = textView2.text
            translationArr.inputAndResultData = textView1.text + textView2.text
            self.realm.add(translationArr, update: .modified)
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
