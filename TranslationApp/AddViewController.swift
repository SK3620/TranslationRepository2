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
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
    var recordViewController: RecordViewController!
    
    var dateString: String!
    var dateString2: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let someArr = [textField1, textField2, textField3, textField4]
        for someNumber in someArr{
            someNumber!.inputAccessoryView = doneToolbar
        }
        textView1.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        textField1.endEditing(true)
        textField2.endEditing(true)
        textField3.endEditing(true)
        textField4.endEditing(true)
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
        let textView_text1 = self.textView1.text
        
       let record = Record()
        
        record.folderName = textField_text1!
        record.number = textField_text2!
        record.times = textField_text3!
        record.nextReviewDate = textField_text4!
        record.memo = textView_text1!
        record.date3 = self.dateString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let _: String = formatter.string(from: record.date4)
        
       
        
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
            }
        } catch {
            print("エラー発生")
        }
        
        self.dismiss(animated: true)
        
    }
    


/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
