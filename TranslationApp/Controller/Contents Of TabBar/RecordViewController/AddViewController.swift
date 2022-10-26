//
//  AddViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/16.
//

import UIKit
import RealmSwift
import SVProgressHUD

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
    
    var pickerView1: UIPickerView = UIPickerView()
    var pickerView3: UIPickerView = UIPickerView()
    var datePicker: UIDatePicker = UIDatePicker()
    
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
        
        label1.text = self.dateString2
          
        self.textField3.delegate = self
        
//        復習回数を１〜３０回に設定
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
        
        setDoneToolBarForTextField1()
        setDoneToolBarForTextField3()
        setDoneTooBarForTextField4()
        setDoneToolBarForTextView1()
        
//        dataPickerのデフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        datePicker.date = formatter.date(from: dateString)!
        
      
        let textFieldArr: [UITextField]! = [textField1, textField2, textField3, textField4]
        setTextField(textFieldArr: textFieldArr)
        
        textView1.layer.borderWidth = 2
        textView1.layer.borderColor = UIColor.gray.cgColor
        textView1.layer.cornerRadius = 6
    }
    
    
    func setTextField(textFieldArr: [UITextField]){
        textFieldArr.forEach{
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.gray.cgColor
            $0.layer.cornerRadius = 6
        }
    }
    
    
    func setDoneToolBarForTextField1(){
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
    }
    
    
    func setDoneToolBarForTextField3(){
        pickerView3.delegate = self
        pickerView3.dataSource = self
        pickerView3.showsSelectionIndicator = true
        // 決定バーの生成
        let toolbar3 = UIToolbar()
        toolbar3.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
       let doneItem3 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done3))
       let cancelItem3 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel3))
       toolbar3.setItems([cancelItem3, spaceItem, doneItem3], animated: true)
       // インプットビュー設定
       textField3.inputView = pickerView3
       textField3.inputAccessoryView = toolbar3
    }
    
    
    func setDoneTooBarForTextField4(){
        // 決定バーの生成
        let toolbar4 = UIToolbar()
         toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done4))
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        textField4.inputView = datePicker
        textField4.inputAccessoryView = toolbar4
    }
    
    
    func setDoneToolBarForTextView1(){
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
        
        SVProgressHUD.show()
        
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
        record.date1 = self.dateString
        record.inputDate = self.dateString2
        if textField_text4 != "" {
            record.nextReviewDateForSorting = textField_text4ForSorting!
        } else {
            record.nextReviewDateForSorting = 0
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let _: String = formatter.string(from: record.date2)
        
        
        if self.recordArr.count != 0 {
            record.id = recordArr.max(ofProperty: "id")! + 1
        }
        
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(record)

                self.recordViewController.recordArrFilter0 = self.recordArr
                self.recordViewController.number = 1
                self.recordViewController.dateString = self.dateString
                

                SVProgressHUD.showSuccess(withStatus: "追加しました")
            }
        } catch {
            print("エラー発生")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in
            SVProgressHUD.dismiss()
        })
       
        print(recordArr)
        
        self.dismiss(animated: true)
        
    }
    
    func stringToDate(dateString: String, fromFormat: String) -> Date? {
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateFormat = fromFormat
            return formatter.date(from: dateString)
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.recordViewController.calendar(recordViewController.fscalendar, numberOfEventsFor: self.selectedDate)
       
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
            self.label2.text = "〜 Tip 〜" + "\n" + "入力した前回の学習記録欄（\(textField3_text - 1)回目の学習記録欄) に「復習完了マーク✅」をつけよう！"
        } else {
            label2.text = ""
        }
    }
}
