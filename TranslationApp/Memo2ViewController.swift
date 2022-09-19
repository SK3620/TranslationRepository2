//
//  Memo2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/19.
//

import UIKit
import RealmSwift
import XCTest

class Memo2ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    let realm = try! Realm()
    let memo2Arr = try! Realm().objects(Memo.self)
    let memo = Memo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.textView.text = memo2Arr[0].memo2
        
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
