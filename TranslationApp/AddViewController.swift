//
//  AddViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/16.
//

import UIKit
import RealmSwift

class AddViewController: UIViewController {
    
    
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textView1: UITextView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    var datePicker: UIDatePicker = UIDatePicker()
    var pickerView1: UIPickerView = UIPickerView()
    var pickerView3: UIPickerView = UIPickerView()

    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
   
    var recordViewController: RecordViewController!
    var translationFolderArr: Results<TranslationFolder>!
    
    var dateString: String!
    var dateString1: Int!
    var dateString2: String!
    var folderNames = [String]()
    
    var toolBar: UIToolbar!
    
    var number: Int!
    var numbers = [String]()
    
//    recordViewController画面で選択された日付を格納する
    var selectedDate: Date!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("選択された日付確認　: \(self.selectedDate)")
        
        self.textField3.delegate = self
        
        for number in 1...30 {
            let number = String(number)
            self.numbers.append(number)
        }
        
         translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        if translationFolderArr.count != 0 {
            for number in 0...translationFolderArr.count - 1{
                self.folderNames.append(translationFolderArr[number].folderName)
            }
        }
        
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView1.showsSelectionIndicator = true
        // 決定バーの生成
        let toolbar1 = UIToolbar()
        toolbar1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
       let doneItem1 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done1))
       let cancelItem1 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel1))
       toolbar1.setItems([cancelItem1, spaceItem, doneItem1], animated: true)
       // インプットビュー設定
       textField1.inputView = pickerView1
       textField1.inputAccessoryView = toolbar1
        
        
        
        pickerView3.delegate = self
        pickerView3.dataSource = self
        pickerView3.showsSelectionIndicator = true
        // 決定バーの生成
        let toolbar3 = UIToolbar()
        toolbar3.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
       let doneItem3 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done3))
       let cancelItem3 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel3))
       toolbar3.setItems([cancelItem3, spaceItem, doneItem3], animated: true)
       // インプットビュー設定
       textField3.inputView = pickerView3
       textField3.inputAccessoryView = toolbar3
        
        
        
        
       
       
        // ピッカー設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        // 決定バーの生成
        let toolbar4 = UIToolbar()
         toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done4))
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        textField4.inputView = datePicker
        textField4.inputAccessoryView = toolbar4
//        デフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        datePicker.date = formatter.date(from: dateString)!
        
        
        label1.text = self.dateString2
    
        
        let borderColor = UIColor.gray.cgColor
        
        textField1.layer.borderWidth = 2.5
        textField1.layer.borderColor = borderColor
        textField1.layer.cornerRadius = 10
        
        
        textField2.layer.borderWidth = 2.5
        textField2.layer.borderColor = borderColor
        textField2.layer.cornerRadius = 10
        
        
        textField3.layer.borderWidth = 2.5
        textField3.layer.borderColor = borderColor
        textField3.layer.cornerRadius = 10
        
        
        textField4.layer.borderWidth = 2.5
        textField4.layer.borderColor = borderColor
        textField4.layer.cornerRadius = 10
       
        
        textView1.layer.borderWidth = 2.5
        textView1.layer.borderColor = borderColor
        textView1.layer.cornerRadius = 10
        
        button1.layer.borderWidth = 2.5
        button1.layer.borderColor = borderColor
        button1.layer.cornerRadius = 10
        
        button2.layer.borderWidth = 2.5
        button2.layer.borderColor = borderColor
        button2.layer.cornerRadius = 10

        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        let someArr = [textField2]
        for someNumber in someArr{
            someNumber!.inputAccessoryView = doneToolbar
        }
        textView1.inputAccessoryView = doneToolbar
    }
    
    
    
    @objc func done1(){
        textField1.endEditing(true)
        if self.folderNames.count != 0 {
        textField1.text = "\(self.folderNames[pickerView1.selectedRow(inComponent: 0)])"
        } else {
            textField1.text = ""
        }
    }
    
    @objc func cancel1(){
        textField1.endEditing(true)
        textField1.text = ""
    }
    
    @objc func done3(){
        textField3.endEditing(true)
        textField3.text = "\(self.numbers[pickerView3.selectedRow(inComponent: 0)])"
    }
    
    @objc func cancel3(){
        textField3.endEditing(true)
        textField3.text = ""
        self.label2.text = ""
    }
    
    @objc func done4(){
        textField4.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        let dateString = formatter.string(from: datePicker.date)
        textField4.text = dateString
        
        formatter.dateFormat = "yyyyMd"
        self.dateString1 = Int(formatter.string(from: datePicker.date))!
        
        print("日付\(Int(dateString1))")
    }
    
    @objc func cancel4(){
        textField4.endEditing(true)
        textField4.text = ""
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        textField2.endEditing(true)
        textView1.endEditing(true)
    }        // Do any additional setup after loading the view.
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        
        let textField_text1 = self.textField1.text
        let textField_text2 = self.textField2.text
        let textField_text3 = self.textField3.text
        let textField_text4 = self.textField4.text
        let textField_text4ForSorting = dateString1
        let textView_text1 = self.textView1.text
        
       let record = Record()
        record.folderName = textField_text1!
        record.number = textField_text2!
        record.times = textField_text3!
        record.nextReviewDate = textField_text4!
        record.memo = textView_text1!
        record.date3 = self.dateString
        if textField_text4 != "" {
        record.nextReviewDateForSorting = textField_text4ForSorting!
        } else {
            record.nextReviewDateForSorting = 0
        }
        
//       let record1 = Record1()
//        record1.folderName2 = textField_text1!
//        record1.number2 = textField_text2!
//        record1.times2 = textField_text3!
//        record1.nextReviewDate2 = textField_text4!
//        record1.memo2 = textView_text1!
//        record1.date3_5 = self.dateString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let _: String = formatter.string(from: record.date4)
//        let _: String = formatter.string(from: record1.date4_5)
        
       
        
        if self.recordArr.count != 0 {
            record.id = recordArr.max(ofProperty: "id")! + 1
        }
//        if self.record1Arr.count != 0 {
//            record1.id = record1Arr.max(ofProperty: "id")! + 1
//        }
       
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(record)
//                realm.add(record1)
                
                self.recordViewController.recordArrFilter0 = self.recordArr
                self.recordViewController.number = 1
                self.recordViewController.dateString = self.dateString
                
//                self.recordViewController.recordArrFilter00 = self.record1Arr
            }
        } catch {
            print("エラー発生")
        }
       
        print(recordArr)
        
        self.dismiss(animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.recordViewController.calendar(recordViewController.fscalendar, numberOfEventsFor: self.selectedDate)
        print("selecteddate確認 : \(self.selectedDate)")
        print("ViewWillDissapearが呼ばれました。")
    }
    
}
    
  
   

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        ドラムロールの列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        ドラムロールの行数
        return pickerView == pickerView1 ? self.folderNames.count : 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerView == pickerView1 ? self.folderNames[row] : self.numbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView1 {
            self.textField1.text = self.folderNames[row]
        } else {
            self.textField3.text = self.numbers[row]
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.textField3 && textField3.text != "" && textField3.text != "1" {
            let textField3_text: Int = Int(textField3.text!)!
            self.label2.text = "〜 Tip 〜" + "\n" + "追加ボタンを押したら" + "\n" + "入力した前回の学習記録（\(textField3_text - 1)回目の学習記録) を「削除する」 or 「完了マークをつける」といいかも！" + "\n" + "学習記録カレンダーを見やすくしよう！"
        } else {
            label2.text = ""
        }
    }
}
