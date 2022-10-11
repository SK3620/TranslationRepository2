//
//  TabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import UIKit
import SVProgressHUD
import RealmSwift

class TabBarController: UITabBarController {
    
    var tabBarController1: UITabBarController!
    let realm = try! Realm()
    var translationFolder: TranslationFolder!
    var array = [String]()
//    var historyViewController: HistoryViewController!
//    var tabBarController2: TabBarController!
    var maxCharactersLength: Int = 13
    

    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.selectedIndex = 2
        // タブアイコンの色
        self.tabBar.tintColor = UIColor.systemBlue
            // タブバーの背景色を設定
            let appearance = UITabBarAppearance()
        appearance.backgroundColor =  UIColor.systemGray4
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        
    
        
        let navigationController0 = viewControllers![0] as! UINavigationController
        let rirekiViewController = navigationController0.viewControllers[0] as! RirekiViewController
        rirekiViewController.tabBarController1 = self
        
        let navigationController1 = viewControllers![1] as! UINavigationController
        let historyViewController = navigationController1.viewControllers[0] as! HistoryViewController
        historyViewController.tabBarController1 = self
        
        let navigationController2 = viewControllers![2] as! UINavigationController
        let translateViewController = navigationController2.viewControllers[0] as! TranslateViewController
        translateViewController.tabBarController1 = self
        
        let navigationController3 = viewControllers![3] as! UINavigationController
        let phraseViewController = navigationController3.viewControllers[0] as! PhraseViewController
        phraseViewController.tabBarController1 = self
        
        let navigationController4 = viewControllers![4] as! UINavigationController
        let recordViewController = navigationController4.viewControllers[0] as! RecordViewController
        recordViewController.tabBarController1 = self
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("遷移しました")
        
        if segue.identifier == "ToCreateViewContoller" {
        let createFolderController = segue.destination as! CreateFolderViewController
        createFolderController.tabBarController2 = self
        }
        
    }
    
    func tableViewReload(){
        if selectedIndex == 1 {
            let navigationController = viewControllers![1] as! UINavigationController
            let historyViewController = navigationController.viewControllers[0] as! HistoryViewController
            historyViewController.tableView.reloadData()
            print("確認50")
        }
    }
    
    func setBarButtonItem0(){
            navigationItem.title = "翻訳"
    }
    func setBarButtonItem1(){
            navigationItem.title = "フォルダー"
    }
    func setBarButtonItem2(){
            navigationItem.title = "履歴"
    }
    func setBarButtonItem3(){
            navigationItem.title = "学習記録"
    }
    func setBarButtonItem4(){
            navigationItem.title = "単語・フレーズ"
        
    }
    
    @IBAction func button(_ sender: Any) {
        let alert = UIAlertController(title: "新規フォルダー作成", message: "フォルダーを作成してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addTextField{ (textField) in
            textField.placeholder = "フォルダー名"
            textField.textAlignment = .center
            textField.delegate = self
        }
        alert.addAction(UIAlertAction(title: "作成", style: .default, handler: { (ac) in
            
            if let textField_text = alert.textFields?.first?.text {
                
                let translationFolderArr = self.realm.objects(TranslationFolder.self)
                if translationFolderArr.isEmpty {
                } else {
                    for number in 0...translationFolderArr.count - 1 {
                        self.array.append(translationFolderArr[number].folderName)
                    }
                }
                
                if self.array.contains(textField_text) != true && textField_text != "" {
                    
                    self.translationFolder = TranslationFolder()
                    //                let textFieldText = textField.text!
                    SVProgressHUD.show()
                    
                    //            プライマリーキーであるidに値を設定（他のidと被らないように）
                    let allTranslationFolder = self.realm.objects(TranslationFolder.self)
                    if allTranslationFolder.count != 0 {
                        self.translationFolder.id = allTranslationFolder.max(ofProperty: "id")! + 1
                    }
                    
                    //            （保存時の）現在の日付を取得　またここでidも上記を理由に保存されていると思う。
                    let date = Date()
                    try! self.realm.write{
                        self.translationFolder.folderName = textField_text
                        self.translationFolder.date = date
                        self.realm.add(self.translationFolder)
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: "新規フォルダー\n\(textField_text)\nを追加しました。")
                } else {
                    if textField_text == "" {
                        SVProgressHUD.show()
                        SVProgressHUD.showError(withStatus: "フォルダー名を入力してください")
                    } else if self.array.contains(textField_text) {
                        SVProgressHUD.show()
                        SVProgressHUD.showError(withStatus: "同じフォルダー名は作成できません")
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in SVProgressHUD.dismiss()})
                self.tableViewReload()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}



extension TabBarController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //        テキストフィールドのセレクションが変更される度に実行される　ここでテキストの最大文字数とスペースの規制を行う
        guard let textField_text = textField.text else {return}
        
        if textField_text.count > self.maxCharactersLength {
            textField.text = String(textField_text.prefix(self.maxCharactersLength))
        }
    }
}
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation



