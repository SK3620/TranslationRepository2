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
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var textView1: UITextView!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!

    var pickerView1: UIPickerView = .init()
    var pickerView3: UIPickerView = .init()
    var datePicker: UIDatePicker = .init()

    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)

    var recordViewController: RecordViewController!
    var translationFolderArr: Results<TranslationFolder>!

    //    RecordViewControllerからの遷移時に渡される、タップされた日付を格納する変数 "yyyyMMdd"
    var dateString: String!
    //　　上と同じ　タップされた日付 "\(year).\(month).\(day)"
    var dateString2: String!
    //    nextReviewDateForSorting（Int型にした日付）を格納する変数
    var dateStringForSorting: Int!
    var folderNames = [String]()
    var numbers = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //        "\(year).\(month).\(day)"をラベルに表示
        self.label1.text = self.dateString2

        self.textField3.delegate = self

        //        復習回数を１〜３０回に設定
        for number in 1 ... 30 {
            let number = String(number)
            self.numbers.append(number)
        }

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.translationFolderArr.forEach {
            self.folderNames.append($0.folderName)
        }

        self.setDoneToolBarForTextField1()
        self.setDoneToolBarForTextField3()
        self.setDoneTooBarForTextField4()
        self.setDoneToolBarForTextView1()

        //        dataPickerのデフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        self.datePicker.date = formatter.date(from: dateString)!

        let textFieldArr: [UITextField]! = [textField1, textField2, textField3, textField4]
        self.setTextField(textFieldArr: textFieldArr)

        self.textView1.layer.borderWidth = 2
        self.textView1.layer.borderColor = UIColor.gray.cgColor
        self.textView1.layer.cornerRadius = 6
    }

    func setTextField(textFieldArr: [UITextField]) {
        textFieldArr.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.gray.cgColor
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

    func setDoneTooBarForTextField4() {
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = NSTimeZone.local
        self.datePicker.locale = Locale.current
        // 決定バーの生成
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

    @IBAction func backButton(_: Any) {
        dismiss(animated: true)
    }

    @IBAction func addButtonAction(_: Any) {
        SVProgressHUD.show()

        let textField_text1 = self.textField1.text
        let textField_text2 = self.textField2.text
        let textField_text3 = self.textField3.text
        //        String型の次回復習日"yyyy.M.d"
        let textField_text4 = self.textField4.text
        //        Int型の次回復習日"yyyyMd'
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
        record.inputDate = self.dateString2
        if textField_text4 != "" {
            //            Int型に変換したyyyyMMdd
            record.nextReviewDateForSorting = textField_text4ForSorting!
        } else {
            //            何も入力がなければ、12月31日以降をInt型で指定　並べ替え時に一番下に表示される
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { () in
            SVProgressHUD.dismiss()
        }
        dismiss(animated: true)
    }
}

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.textField3, self.textField3.text != "", self.textField3.text != "1" {
            let textField3_text: Int = .init(textField3.text!)!
            self.label2.text = "〜 Tip 〜" + "\n" + "入力した前回の学習記録欄（\(textField3_text - 1)回目の学習記録欄) に「復習完了マーク✅」をつけよう！"
        } else {
            self.label2.text = ""
        }
    }
}
