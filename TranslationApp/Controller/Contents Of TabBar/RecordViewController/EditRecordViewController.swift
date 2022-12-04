//
//  EditViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15.
//

import RealmSwift
import SVProgressHUD
import UIKit

class EditRecordViewController: UIViewController, UINavigationBarDelegate {
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var textView1: UITextView!
    @IBOutlet var view1: UIView!

    var datePicker: UIDatePicker = .init()
    var pickerView1: UIPickerView = .init()
    var pickerView3: UIPickerView = .init()

    var translationFolderArr: Results<TranslationFolder>!

    var folderNames = [String]()

    var toolBar: UIToolbar!

//    var number: Int!

    var numbers = [String]()

    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
    var recordArrFilter2: Record!

    var recordViewController: RecordViewController!
    var tabBarController1: UITabBarController?
    var dateString: String!
    var dateString1: Int!
    var studyViewContoller: StudyViewController!

    //    タップされた日付をタイトルに表示
    var label1_text: String!
    var textField1_text: String!
    var textField2_text: String!
    var textField3_text: String!
    var textField4_text: String!
    var textView1_text: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()

        for number in 1 ... 30 {
            let number = String(number)
            self.numbers.append(number)
        }

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        if self.translationFolderArr.count != 0 {
            self.translationFolderArr.forEach {
                self.folderNames.append($0.folderName)
            }
        }
        //        デフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        self.datePicker.date = formatter.date(from: dateString)!

        let textFieldArr: [UITextField] = [self.textField1, self.textField2, self.textField3, self.textField4]
        self.SetTextFields(textFieldArr: textFieldArr)

        self.textView1.layer.borderWidth = 2
        self.textView1.layer.borderColor = UIColor.systemGray2.cgColor
        self.textView1.layer.cornerRadius = 6

        self.textField1.text = self.textField1_text
        self.textField2.text = self.textField2_text
        self.textField3.text = self.textField3_text
        self.textField4.text = self.textField4_text
        self.textView1.text = self.textView1_text

        self.setPlaceHolderForTextField()
        self.setDoneToolBarForTextField1()
        self.setDoneToolBarForTextField3()
        self.setDoneToolBarForTextField4()
        self.setDoneToolBarForTextView1()
    }

    func setPlaceHolderForTextField() {
        self.textField1.attributedPlaceholder = NSAttributedString(string: "学習したフォルダー名",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField2.attributedPlaceholder = NSAttributedString(string: "学習した文章番号/内容(例:1〜10)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField3.attributedPlaceholder = NSAttributedString(string: "復習した回数(〜回目)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField4.attributedPlaceholder = NSAttributedString(string: "次回復習日を設定しよう！", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    func setNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
        self.navigationController?.navigationBar.standardAppearance = appearence

        let rightBarButtonItem = UIBarButtonItem(title: "編集完了", style: .done, target: self, action: #selector(self.tappedRightBarButtonItem(_:)))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]

//        日付を表示
        self.title = self.label1_text
    }

    func SetTextFields(textFieldArr: [UITextField]!) {
        textFieldArr.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.systemGray3.cgColor
            $0.layer.cornerRadius = 6
        }
    }

    func setDoneToolBarForTextField1() {
        self.pickerView1.delegate = self
        self.pickerView1.dataSource = self
        self.pickerView1.showsSelectionIndicator = true
        // 決定バーの生成
        let toolbar1 = UIToolbar()
        toolbar1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem1 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done1))
        let cancelItem1 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(self.cancel1))
        toolbar1.setItems([cancelItem1, spaceItem, doneItem1], animated: true)
        // インプットビュー設定
        self.textField1.inputView = self.pickerView1
        self.textField1.inputAccessoryView = toolbar1
    }

    func setDoneToolBarForTextField3() {
        self.pickerView3.delegate = self
        self.pickerView3.dataSource = self
        self.pickerView3.showsSelectionIndicator = true
        // 決定バーの生成
        let toolbar3 = UIToolbar()
        toolbar3.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem3 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done3))
        let cancelItem3 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(self.cancel3))
        toolbar3.setItems([cancelItem3, spaceItem, doneItem3], animated: true)
        // インプットビュー設定
        self.textField3.inputView = self.pickerView3
        self.textField3.inputAccessoryView = toolbar3
    }

    func setDoneToolBarForTextField4() {
        // ピッカー設定
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = NSTimeZone.local
        self.datePicker.locale = Locale.current
        // 決定バーの生成
        let toolbar4 = UIToolbar()
        toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done4))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(self.cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        self.textField4.inputView = self.datePicker
        self.textField4.inputAccessoryView = toolbar4
    }

    func setDoneToolBarForTextView1() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        let someArr = [textField2]
        for someNumber in someArr {
            someNumber!.inputAccessoryView = doneToolbar
        }
        self.textView1.inputAccessoryView = doneToolbar
    }

    @objc func done1() {
        self.textField1.endEditing(true)
        if self.folderNames.isEmpty != true {
            self.textField1.text = "\(self.folderNames[self.pickerView1.selectedRow(inComponent: 0)])"
        } else {
            self.textField1.text = ""
        }
    }

    @objc func cancel1() {
        self.textField1.endEditing(true)
        self.textField1.text = ""
    }

    @objc func done3() {
        self.textField3.endEditing(true)
        self.textField3.text = "\(self.numbers[self.pickerView3.selectedRow(inComponent: 0)])"
    }

    @objc func cancel3() {
        self.textField3.endEditing(true)
        self.textField3.text = ""
    }

    @objc func done4() {
        self.textField4.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        let dateString = formatter.string(from: self.datePicker.date)
        self.textField4.text = dateString

        formatter.dateFormat = "yyyyMd"
        self.dateString1 = Int(formatter.string(from: self.datePicker.date))
    }

    @objc func cancel4() {
        self.textField4.endEditing(true)
        self.textField4.text = ""
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.textField2.endEditing(true)
        self.textView1.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.tabBarController1?.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = .systemGray5
        navigationController?.navigationBar.backgroundColor = .systemGray5
    }

//    保存ボタン
    @objc func tappedRightBarButtonItem(_: UIBarButtonItem) {
        SVProgressHUD.show()

        self.textField1_text = self.textField1.text
        self.textField2_text = self.textField2.text
        self.textField3_text = self.textField3.text
        self.textField4_text = self.textField4.text
        let textField4_textForSorting = self.dateString1
        self.textView1_text = self.textView1.text

        do {
            let realm = try Realm()
            try realm.write {
                self.recordArrFilter2.folderName = textField1_text!
                self.recordArrFilter2.number = textField2_text!
                self.recordArrFilter2.times = textField3_text!
                self.recordArrFilter2.nextReviewDate = textField4_text!
                self.recordArrFilter2.memo = textView1_text!
                self.recordArrFilter2.nextReviewDateForSorting = textField4_textForSorting!
                realm.add(self.recordArrFilter2, update: .modified)
            }
            self.recordViewController.dateString = self.dateString
            self.recordViewController.filteredRecordArr(recordArrFilter1: self.recordArr)

            SVProgressHUD.showSuccess(withStatus: "保存しました")
        } catch {
            print("エラー発生")
        }
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension EditRecordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        //        ドラムロールの列数
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        //        ドラムロールの行数
        return pickerView == self.pickerView1 ? self.folderNames.count : 30
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return pickerView == self.pickerView1 ? self.folderNames[row] : self.numbers[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if pickerView == self.pickerView1 {
            self.textField1.text = self.folderNames[row]
        } else {
            self.textField3.text = self.numbers[row]
        }
    }
}
