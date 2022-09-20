//
//  Memo2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/19.
//

import UIKit
import RealmSwift

class Memo2ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    let realm = try! Realm()
    let memo2Arr = try! Realm().objects(Memo.self)
    let memo = Memo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.delegate = self
        
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.textView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        textView.endEditing(true)
      
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.memo2Arr.count != 0 {
        self.textView.text = memo2Arr[0].memo2
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        do {
            let realm = try Realm()
            try realm.write{
                self.memo.memo2 = self.textView.text
                realm.add(memo.self, update: .modified)
            }
        } catch {
            print("エラー")
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
