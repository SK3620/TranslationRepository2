//
//  HistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import RealmSwift
import SVProgressHUD
import Alamofire
import AVFAudio
import AVFoundation

class FolderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    var folderNameString: String?
    var resultsArr = [TranslationFolder]()
    var tabBarController1: TabBarController!
    
    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder> = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let speak = Speak()
        speak.playInputData = false
//        入力した文章を音声読み上げ
        speak.playResultData = true
//        翻訳結果を音声読み上げ
        try! Realm().write{
            self.realm.add(speak, update: .modified)
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .systemBlue
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        //        何も入力されていなくてもreturnキー押せるようにする
        searchBar.enablesReturnKeyAutomatically  = false
    
        //キーボードに完了のツールバーを作成
        self.setDoneOnKeyBoard()
    }
    
//    検索時の完了のボタンタップ時
    @objc func doneButtonTaped(sender: UIButton){
        self.searchBar.endEditing(true)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
       
//        StudyViewControllerで音声再生されていたら、音声停止する
        AVSpeechSynthesizer().stopSpeaking(at: .immediate)
        
//        フォルダーがない場合、画面に表示
        self.label.text = "右上のボタンでフォルダーを作成しよう！"
        editButton.setTitle("編集", for: .normal)
        tableView.isEditing = false
        

        self.navigationController!.setNavigationBarHidden(true, animated: false)
        tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController1.setBarButtonItem1()
      
        
        if translationFolderArr.count == 0 {
            editButton.isEnabled = false
        }
        
        tableView.reloadData()
    }
    
//     検索ボタン押下時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        検索欄に何もなければ
        if self.searchBar.text == "" {
            translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
            
        } else {
//            あれば、
            translationFolderArr = self.translationFolderArr.filter("folderName CONTAINS '\(self.searchBar.text!)'")
//            検索欄に入力があり、さらにtranslationFolderArrが空なら、全て表示する
           if translationFolderArr.count == 0 {
               translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
            }
        }
        
        tableView.reloadData()
        
        
    }
    
    
    func tableViewReload(){
        translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.tableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if translationFolderArr.count == 0 {
            tableView.isEditing = false
            self.label.text = "右上のボタンでフォルダーを作成しよう！"
            editButton.setTitle("編集", for: .normal)
            editButton.isEnabled = false
        } else {
            self.label.text = ""
            editButton.isEnabled = true
        }
        return translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.numberOfLines = 0
        
//        セルに内容設定
        cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = self.translationFolderArr[indexPath.row].folderName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        
        let dateString: String = formatter.string(from: self.translationFolderArr[indexPath.row].date)
        cell.detailTextLabel?.text = "作成日:\(dateString)"
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! realm.write  {
                self.realm.delete(self.translationFolderArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
        }
    }
    
//    セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            var translationFolderArr = try! Realm().objects(TranslationFolder.self)
            
        self.folderNameString = self.translationFolderArr[indexPath.row].folderName
            
            let predict = NSPredicate(format: "folderName == %@", folderNameString!)
            translationFolderArr =  translationFolderArr.filter(predict)
            
        tableView.deselectRow(at: indexPath, animated: true)
                  
//        resultsに何も値があれば、フォルダー名をhitory2ViewControllerへ渡す+画面遷移
            if translationFolderArr[0].results.count != 0 {
               
                let studyViewContoller = self.storyboard!.instantiateViewController(withIdentifier: "StudyViewController") as! StudyViewController
                
                studyViewContoller.folderNameString = folderNameString!
                
                self.performSegue(withIdentifier: "ToStudyViewController", sender: self.folderNameString)
//                number = 1
                
            } else {
                SVProgressHUD.show()
                SVProgressHUD.showError(withStatus: "'\(self.folderNameString!)' フォルダー内に保存されたデータがありません")
//                number = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in
                    SVProgressHUD.dismiss()
                })
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToStudyViewController" {
            let studyViewController = segue.destination as! StudyViewController
            studyViewController.folderNameString = sender as! String
            studyViewController.tabBarController1 = self.tabBarController1
        }
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        if tableView.isEditing {
            tableView.isEditing = false
            editButton.setTitle("編集", for: .normal)
        } else {
            tableView.isEditing = true
            editButton.setTitle("完了", for: .normal)
        }
    }
    
    
    func setDoneOnKeyBoard(){
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }
    
    
}






// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


