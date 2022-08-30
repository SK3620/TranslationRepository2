//
//  CreateFolderViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import SVProgressHUD
import RealmSwift

class CreateFolderViewController: UIViewController {
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    
    
    
//    Realmインスタンス取得
    let realm = try! Realm()
    var realmDataBase: RealmDataBase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        view2.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        
       
//        ボタン外枠の色と太さ設定
//        cancelButton.layer.borderColor = UIColor.gray.cgColor
//        cancelButton.layer.borderWidth = 1.0
//
//        SaveButton.layer.borderColor = UIColor.gray.cgColor
//        SaveButton.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField?.becomeFirstResponder()
    }
    
//    自動的に閉じる場合　self.textView.resignFirstResponder()
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
//    保存ボタン
    @IBAction func saveButton(_ sender: Any) {
        if textField.text! != "" {
            self.realmDataBase = RealmDataBase()
            let textFieldText = textField.text!
            SVProgressHUD.show()
            
//            プライマリーキーであるidに値を設定（他のidと被らないように）
            let allRealmData = realm.objects(RealmDataBase.self)
            if allRealmData.count != 0 {
                self.realmDataBase.id = allRealmData.max(ofProperty: "id")! + 1
            }
            
            //            （保存時の）現在の日付を取得　またここでidも上記を理由に保存されていると思う。
            let date = Date()
            try! realm.write{
                self.realmDataBase.folderName = textFieldText
                self.realmDataBase.date = date
                self.realm.add(self.realmDataBase)
            }
            
            SVProgressHUD.showSuccess(withStatus: "新規フォルダー : \(textFieldText) を追加しました。")
            
            self.dismiss(animated: true)
            self.textField?.text = nil
            
        } else {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "フォルダー名を入力してください")
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

////現在の日付を取得
//let date:Date = Date()
////日付のフォーマットを指定する。
//let format = DateFormatter()
//format.dateFormat = "yyyy/MM/dd HH:mm:ss"
////日付をStringに変換する
//let sDate = format.string(from: date)
////from: date　は、 formatする現在の日付であるdateを入れる。


