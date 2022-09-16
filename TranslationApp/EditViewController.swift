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
    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
    var recordArrFilter2: Record!
    
    var recordViewController: RecordViewController!
    var dateString: String!
    
    var label1_text: String!
    var textField1_text: String!
    var textField2_text: String!
    var textField3_text: String!
    var textField4_text: String!
    var textView1_text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
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
         textView1_text = self.textView1.text
        
        do {
            let realm = try Realm()

            try realm.write {
                self.recordArrFilter2.folderName = textField1_text!
                self.recordArrFilter2.number = textField2_text!
                self.recordArrFilter2.times = textField3_text!
                self.recordArrFilter2.nextReviewDate = textField4_text!
                self.recordArrFilter2.memo = textView1_text!
                realm.add(self.recordArrFilter2, update: .modified)
            }
            
            self.recordViewController.recordArrFilter0 = self.recordArr
            self.recordViewController.number = 1
            self.recordViewController.dateString = self.dateString
            
        } catch {
            print("エラー発生")
        }
        
        self.dismiss(animated: true)
    }
    
    
    
    
    @IBAction func button1Action(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
  
    

}
