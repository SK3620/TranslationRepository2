//
//  MemoViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/12.
//

import UIKit
import RealmSwift

class MemoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var memoButton: UIButton!
    
    
    
    var folderNameString: String!
    var realm = try! Realm()
    var memoTextViewText = ""
    
    override func viewDidLoad() {
    super.viewDidLoad()
        
        
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        memoTextView.inputAccessoryView = doneToolbar
        
        
        let borderColor = UIColor.gray.cgColor
        self.memoButton.layer.borderColor = borderColor
        self.memoButton.layer.borderWidth = 2.5
        self.memoButton.layer.cornerRadius = 10
        
        memoTextView.delegate = self

        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    //完了ボタンタップ時に、キーボードを閉じる
    @objc
    func doneButtonTaped(sender: UIButton) {
        memoTextView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let memo = try! Realm().objects(TranslationFolder.self).filter("folderName == %@", self.folderNameString!).first!.memo
        
        self.memoTextView.text = memo
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let memoTextViewText1 = self.memoTextView.text {
            
            let translationFolderArr = try! Realm().objects(TranslationFolder.self).filter("folderName == %@",  self.folderNameString!).first
            
            try! realm.write{
                translationFolderArr!.memo = memoTextViewText1
                self.realm.add(translationFolderArr!, update: .modified)
            }
            
            self.memoTextViewText = memoTextViewText1
        }
        
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






