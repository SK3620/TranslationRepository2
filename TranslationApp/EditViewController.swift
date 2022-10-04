//
//  EditViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController {
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    var datePicker: UIDatePicker = UIDatePicker()
    var pickerView1: UIPickerView = UIPickerView()
    var pickerView3: UIPickerView = UIPickerView()
    
    var translationFolderArr: Results<TranslationFolder>!
    
    var folderNames = [String]()
    
    var toolBar: UIToolbar!
    
    var number: Int!
    
    var numbers = [String]()
    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
    var recordArrFilter2: Record!
//    let record1Arr = try! Realm().objects(Record1.self)
//    var record1ArrFilter2: Record1!
    
    var recordViewController: RecordViewController!
    var dateString: String!
    var dateString1: Int!
    
    var label1_text: String!
    var textField1_text: String!
    var textField2_text: String!
    var textField3_text: String!
    var textField4_text: String!
    var textView1_text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let color = UIColor.gray.cgColor
        
        button1.layer.borderWidth = 2
        button1.layer.borderColor = color
        button1.layer.cornerRadius = 10
    
        button2.layer.borderWidth = 2
        button2.layer.borderColor = color
        button2.layer.cornerRadius = 10
        
        textField1.layer.borderWidth = 2
        textField1.layer.borderColor = color
        textField1.layer.cornerRadius = 10
        
        textField2.layer.borderWidth = 2
        textField2.layer.borderColor = color
        textField2.layer.cornerRadius = 10
        
        textField3.layer.borderWidth = 2
        textField3.layer.borderColor = color
        textField3.layer.cornerRadius = 10
        
        textField4.layer.borderWidth = 2
        textField4.layer.borderColor = color
        textField4.layer.cornerRadius = 10
        
        textView1.layer.borderWidth = 2
        textView1.layer.borderColor = color
        textView1.layer.cornerRadius = 10
        
        self.label1.text = self.label1_text
        self.textField1.text = self.textField1_text
        self.textField2.text = self.textField2_text
        self.textField3.text = self.textField3_text
        self.textField4.text = self.textField4_text
        self.textView1.text = self.textView1_text
        
        
        
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
        textField1.text = "\(self.folderNames[pickerView1.selectedRow(inComponent: 0)])"
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
    }
    
    @objc func done4(){
        textField4.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        let dateString = formatter.string(from: datePicker.date)
        textField4.text = dateString
        
        formatter.dateFormat = "yyyyMd"
        self.dateString1 = Int(formatter.string(from: datePicker.date))
    }
    
    @objc func cancel4(){
        textField4.endEditing(true)
        textField4.text = ""
    }
    @objc func doneButtonTaped(sender: UIButton){
        textField2.endEditing(true)
        textView1.endEditing(true)
    }
        // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    保存ボタン
    @IBAction func Button2Action(_ sender: Any) {
         textField1_text = self.textField1.text
         textField2_text = self.textField2.text
         textField3_text = self.textField3.text
         textField4_text = self.textField4.text
        let textField4_textForSorting = self.dateString1
         textView1_text = self.textView1.text
        
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
                
//                self.record1ArrFilter2.folderName2 = textField1_text!
//                self.record1ArrFilter2.number2 = textField2_text!
//                self.record1ArrFilter2.times2 = textField3_text!
//                self.record1ArrFilter2.nextReviewDate2 = textField4_text!
//                self.record1ArrFilter2.memo2 = textView1_text!
//                realm.add(self.record1ArrFilter2, update: .modified)
                
                
            }
            
            self.recordViewController.recordArrFilter0 = self.recordArr
            self.recordViewController.number = 1
            self.recordViewController.dateString = self.dateString
            
//            self.recordViewController.recordArrFilter00 = self.record1Arr
            
            print("チェック \(recordArr)")
//            print(record1Arr)
            
        } catch {
            print("エラー発生")
        }
        
        self.dismiss(animated: true)
    }
    
    
    
    
    @IBAction func button1Action(_ sender: Any) {
        self.dismiss(animated: true)
    }

}


extension EditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    }}
