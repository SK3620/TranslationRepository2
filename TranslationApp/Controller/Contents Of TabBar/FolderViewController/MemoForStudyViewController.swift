//
//  MemoViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/12.
//

import RealmSwift
import SVProgressHUD
import UIKit

class MemoForStudyViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var memoTextView: UITextView!
    
    var folderNameString: String!
    
    private var memoTextViewText = ""
    
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDoneToolBar()
        
        self.memoTextView.delegate = self
        
        view.backgroundColor = UIColor.white
    }
    
    private func setDoneToolBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.memoTextView.inputAccessoryView = doneToolbar
    }
    
    @objc
    func doneButtonTaped(sender _: UIButton) {
        self.memoTextView.endEditing(true)
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        //retrive the memo data by filtering with self.folderNameString passed to self from StudyVC when screen tansition to self
        let memo = try! Realm().objects(TranslationFolder.self).filter("folderName == %@", self.folderNameString!).first!.memo
        self.memoTextView.text = memo
    }
    
    @IBAction func backBarButtonItem(_: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //a button to save the memo to realm database
    @IBAction func saveBarButtonItem(_: Any) {
        if let memoTextView_text = memoTextView.text {
            let translationFolderArr = try! Realm().objects(TranslationFolder.self).filter("folderName == %@", self.folderNameString!).first
            
            try! self.realm.write {
                translationFolderArr!.memo = memoTextView_text
                self.realm.add(translationFolderArr!, update: .modified)
            }
            self.memoTextViewText = memoTextView_text
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        SVProgressHUD.dismiss(withDelay: 1.0) {
            self.dismiss(animated: true, completion: nil)
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
