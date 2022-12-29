//
//  AddViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/16.
//

import RealmSwift
import SVProgressHUD
import UIKit

class AddViewController: UIViewController {
    @IBOutlet private var textField1: UITextField!
    @IBOutlet private var textField2: UITextField!
    @IBOutlet private var textField3: UITextField!
    @IBOutlet private var textField4: UITextField!

    @IBOutlet private var textView1: UITextView!

    @IBOutlet private var label2: UILabel!

    private var pickerView1: UIPickerView = .init()
    private var pickerView3: UIPickerView = .init()
    private var datePicker: UIDatePicker = .init()

    private let realm = try! Realm()
    private let recordArr = try! Realm().objects(Record.self)

    var recordViewController: RecordViewController!
    var translationFolderArr: Results<TranslationFolder>!

    //   Variable to store the tapped date, passed at transition from RecordViewController    "yyyyMMdd"
    var dateString: String!
    //　　the same as above one  stores the tapped date  "\(year).\(month).\(day)"
    var dateString2: String!
    //    nextReviewDateForSorting  variable to store the tapped Int type date
    var dateStringForSorting: Int!

    var folderNames = [String]()

    var numbers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()

        self.textField3.delegate = self

        // Set the number of review sessions from 1 to 30
        for number in 1 ... 30 {
            let number = String(number)
            self.numbers.append(number)
        }

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.translationFolderArr.forEach {
            self.folderNames.append($0.folderName)
        }

        self.setPlaceHolderForTextField()
        self.setDoneToolBarForTextField1()
        self.setDoneToolBarForTextField3()
        self.setDoneTooBarForTextField4()
        self.setDoneToolBarForTextView1()

        // default settings for dataPicker
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        self.datePicker.date = formatter.date(from: dateString)!

        let textFieldArr: [UITextField]! = [textField1, textField2, textField3, textField4]
        self.setTextField(textFieldArr: textFieldArr)

        self.textView1.layer.borderWidth = 2
        self.textView1.layer.borderColor = UIColor.systemGray2.cgColor
        self.textView1.layer.cornerRadius = 6
    }

    private func setPlaceHolderForTextField() {
        self.textField1.attributedPlaceholder = NSAttributedString(string: "学習したフォルダー名",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField2.attributedPlaceholder = NSAttributedString(string: "学習した文章番号/内容(例:1〜10)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField3.attributedPlaceholder = NSAttributedString(string: "復習した回数(〜回目)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.textField4.attributedPlaceholder = NSAttributedString(string: "次回復習日を設定しよう！", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    // settings for navigationBar
    private func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let rightBarButtonItem = UIBarButtonItem(title: "追加する", style: .done, target: self, action: #selector(self.tappedRightBarButtonImte(_:)))
        let leftBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.tappedLeftBarButtonItem(_:)))
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]

        self.title = self.dateString2
    }

//    back button
    @objc func tappedLeftBarButtonItem(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

//    add button    wrtie the added data to realm database (Record class)
    @objc func tappedRightBarButtonImte(_: UIBarButtonItem) {
        let textField_text1 = self.textField1.text
        let textField_text2 = self.textField2.text
        let textField_text3 = self.textField3.text
        //       string type next review date  "yyyy.M.d"
        let textField_text4 = self.textField4.text
        //        int type next review date    "yyyyMd'
        let textField_text4ForSorting = self.dateStringForSorting
        let textView_text1 = self.textView1.text

        let record = Record()
        record.folderName = textField_text1!
        record.number = textField_text2!
        record.times = textField_text3!
        record.nextReviewDate = textField_text4!
        record.memo = textView_text1!
        //        "yyyyMMdd"
        record.date1 = self.dateString
        //        "\(year).\(month).\(day)"
        record.inputDate = self.today()
        if textField_text4 != "" {
            //            yyyyMMdd which was changed to Int type
            record.nextReviewDateForSorting = textField_text4ForSorting!
        } else {
            // If nothing is entered, Int after Dec 31st Displayed at the bottom of the list when sorting
            record.nextReviewDateForSorting = 1232
        }

        if self.recordArr.count != 0 {
            record.id = self.recordArr.max(ofProperty: "id")! + 1
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(record)
            }
            self.recordViewController.filteredRecordArr(recordArrFilter1: self.recordArr)
            self.recordViewController.dateString = self.dateString
            SVProgressHUD.showSuccess(withStatus: "追加しました")
        } catch {
            print("エラー発生")
        }
        self.recordViewController.fscalendar.reloadData()
        self.recordViewController.tableView.reloadData()
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.dismiss(animated: true)
        }
    }

    // return string type date
    private func today() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let dateString: String = formatter.string(from: Date())
        return dateString
    }

    private func setTextField(textFieldArr: [UITextField]) {
        textFieldArr.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.systemGray3.cgColor
            $0.layer.cornerRadius = 6
        }
    }

    private func setDoneToolBarForTextField1() {
        self.pickerView1.delegate = self
        self.pickerView1.dataSource = self
        self.pickerView1.showsSelectionIndicator = true

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

    private func setDoneToolBarForTextField3() {
        self.pickerView3.delegate = self
        self.pickerView3.dataSource = self
        self.pickerView3.showsSelectionIndicator = true

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

    private func setDoneTooBarForTextField4() {
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = NSTimeZone.local
        self.datePicker.locale = Locale.current

        let toolbar4 = UIToolbar()
        toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done4))
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(self.cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        self.textField4.inputView = self.datePicker
        self.textField4.inputAccessoryView = toolbar4
    }

    private func setDoneToolBarForTextView1() {
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
        if self.folderNames.count != 0 {
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
        self.label2.text = ""
    }

    @objc func done4() {
        self.textField4.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        self.textField4.text = formatter.string(from: self.datePicker.date)

        formatter.dateFormat = "yyyyMd"
        //        取得した日付をInt型に変換
        self.dateStringForSorting = Int(formatter.string(from: self.datePicker.date))
    }

    @objc func cancel4() {
        self.textField4.endEditing(true)
        self.textField4.text = ""
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.textField2.endEditing(true)
        self.textView1.endEditing(true)
    } // Do any additional setup after loading the view.
}

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        //        the number of rows in the dorumroll
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        //        the number of rows in the dorumroll
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.textField3, self.textField3.text != "", self.textField3.text != "1" {
            let textField3_text: Int = .init(textField3.text!)!
            self.label2.text = "入力した前回の学習記録欄（\(textField3_text - 1)回目の学習記録欄) に「復習完了マーク✅」をつけよう！"
        } else {
            self.label2.text = ""
        }
    }
}
