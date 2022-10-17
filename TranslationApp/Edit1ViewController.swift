//
//  Edit1ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import UIKit
import RealmSwift
import SVProgressHUD

class Edit1ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView1: UITextView!
    //    @IBOutlet weak var textViewMemo1: UITextView!
    @IBOutlet weak var textView2: UITextView!
//    @IBOutlet weak var textViewMemo2: UITextView!
//
    //    @IBOutlet weak var button1: UIButton!
//    @IBOutlet weak var button2: UIButton!
   

    var numberForActionButton1: Int = 0
    var numberForActionButton2: Int = 0
    
    var textView1String: String = ""
    var textView2String: String = ""
    var translationIdNumber: Int = 0
    
    var realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView1.delegate = self
        textView2.delegate = self
//        textViewMemo1.delegate = self
//        textViewMemo2.delegate = self
        
        let color = UIColor.gray.cgColor
        
        textView1.layer.borderColor = UIColor.systemGray4.cgColor
        textView1.layer.borderWidth = 2
        
        textView2.layer.borderColor = UIColor.systemGray4.cgColor
        textView2.layer.borderWidth = 2
       
//        textViewMemo1.layer.borderColor = color
//        textViewMemo1.layer.borderWidth = 2
//        textViewMemo1.layer.cornerRadius = 10
        
//        textViewMemo2.layer.borderColor = color
//        textViewMemo2.layer.borderWidth = 2
//        textViewMemo2.layer.cornerRadius = 10
        
//        button1.layer.borderColor = color
//        button1.layer.borderWidth = 2
//        button1.layer.cornerRadius = 10
        
//        button2.layer.borderColor = color
//        button2.layer.borderWidth = 2
//        button2.layer.cornerRadius = 10

      
        
//        button4.layer.borderColor = color
//        button4.layer.borderWidth = 2.5
//        button4.layer.cornerRadius = 10
        
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        let someArr = [self.textView1, self.textView2]
        for someNumber in someArr{
        someNumber!.inputAccessoryView = doneToolbar
        }
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        textView1.endEditing(true)
        textView2.endEditing(true)
    }
    
   
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
        
//        textViewMemo1.isHidden = true
//        textViewMemo1.isEditable = false
//        let image = UIImage(systemName: "arrow.down.square")
//        self.button1.setImage(image, for: .normal)
//        self.button1.setTitle("メモ追加", for: .normal)
//        numberForActionButton1 = 0
        
//        textViewMemo2.isHidden = true
//        textViewMemo2.isEditable = false
//        self.button2.setImage(image, for: .normal)
//        self.button2.setTitle("メモ追加", for: .normal)
//        numberForActionButton1 = 0
        
        textView1.text = self.textView1String
        textView2.text = self.textView2String
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
//    @IBAction func ActionButton1(_ sender: Any) {
//        if self.numberForActionButton1 == 0 {
//            self.textViewMemo1.isEditable = true
//            self.textViewMemo1.isHidden = false
//            self.button1.setTitle("非表示にする", for: .normal)
//            numberForActionButton1 = 1
//        } else {
//            self.textViewMemo1.isEditable = false
//            self.textViewMemo1.isHidden = true
//            let image = UIImage(systemName: "arrow.down.square")
//            self.button1.setImage(image, for: .normal)
//            self.button1.setTitle("メモ追加", for: .normal)
//            numberForActionButton1 = 0
//        }
//    }
    
//    @IBAction func ActionButton2(_ sender: Any) {
//        if self.numberForActionButton2 == 0 {
//            self.textViewMemo2.isEditable = true
//            self.textViewMemo2.isHidden = false
//            self.button2.setTitle("非表示にする", for: .normal)
//            numberForActionButton2 = 1
//        } else {
//            self.textViewMemo2.isEditable = false
//            self.textViewMemo2.isHidden = true
//            let image = UIImage(systemName: "arrow.down.square")
//            self.button2.setImage(image, for: .normal)
//            self.button2.setTitle("メモ追加", for: .normal)
//            numberForActionButton2 = 0
//        }
//    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        if textView1.text! != textView1String || textView2.text! != textView2String {
//            self.button4.isEnabled = true
//        } else {
//            button4.isEnabled = false
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        SVProgressHUD.show()
//        let tarnslation = Translation()
//        let predict = NSPredicate(format: "id == %@", "\(self.translationIdNumber)")
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationIdNumber)").first!
        
        print("確認20 : \(translationArr)")
    
            try! realm.write{
                translationArr.inputData = textView1.text
                translationArr.resultData = textView2.text
                translationArr.inputAndResultData = textView1.text + textView2.text
                self.realm.add(translationArr, update: .modified)
            }
        
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {() -> Void in
            SVProgressHUD.dismiss()})
            
            print("確認17 : \(translationArr.inputData)")
            print("確認17 : \(translationArr.resultData)")
                  
            
       
//            try! realm.write{
//                translationArr.inputData = textView1.text
//                translationArr.resultData = textView2.text
//                self.realm.add(translationArr, update: .modified)
//            }
//        }
    }

    
    
    
}
