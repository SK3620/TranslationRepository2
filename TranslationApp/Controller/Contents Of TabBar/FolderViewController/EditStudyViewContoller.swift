//
//  Edit1ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import UIKit
import RealmSwift
import SVProgressHUD

class EditStudyViewContoller: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    
    
    var textView1String: String = ""
    var textView2String: String = ""
    var translationId: Int = 0
    
    var realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView1.delegate = self
        textView2.delegate = self
        
        let textViewArr: [UITextView] = [textView1, textView2]
       setTextView(textViewArr: textViewArr)
       
       setDoneToolBar()
       
    }
    
    func setTextView(textViewArr: [UITextView]!){
        textViewArr.forEach{
            $0.layer.borderColor = UIColor.systemGray.cgColor
            $0.layer.borderWidth = 2
        }
    }
    
    func setDoneToolBar(){
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
        
        textView1.text = self.textView1String
        textView2.text = self.textView2String
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        SVProgressHUD.show()
        let translationArr = self.realm.objects(Translation.self).filter("id == \(self.translationId)").first!
        
            try! realm.write{
                translationArr.inputData = textView1.text
                translationArr.resultData = textView2.text
                translationArr.inputAndResultData = textView1.text + textView2.text
                self.realm.add(translationArr, update: .modified)
            }
        
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {() -> Void in
            SVProgressHUD.dismiss()})
            
           
    }

    
    
    
}
