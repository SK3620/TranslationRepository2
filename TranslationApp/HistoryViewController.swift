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

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    var folderNameString: String?
    var number: Int = 0
    var resultsArr = [TranslationFolder]()
    var tabBarController1: TabBarController!
    
    let realm = try! Realm()
//    データ一覧を取得
    var translationFolderArr: Results<TranslationFolder> = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .gray
        
        searchBar.backgroundImage = UIImage()
//        tableView.layer.borderColor = UIColor.gray.cgColor
//        tableView.layer.borderWidth = 0.5
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        
        //        何も入力されていなくてもreturnキー押せるようにする
                searchBar.enablesReturnKeyAutomatically  = false
    
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        self.searchBar.endEditing(true)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.label.text = "右上のボタンでフォルダーを作成しよう！"
        
        editButton.setTitle("編集", for: .normal)
        tableView.isEditing = false
        
        self.tabBarController1.setBarButtonItem1()
        
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        if translationFolderArr.count == 0 {
            editButton.isEnabled = false
        }
        tableView.reloadData()
        print("実行された")
        
        self.number = 0
    }
    
//     検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchBar.text == "" {
            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true).sorted(byKeyPath: "date", ascending: true)
            
        } else {
            self.translationFolderArr = self.translationFolderArr.filter("folderName CONTAINS '\(self.searchBar.text!)'").sorted(byKeyPath: "date", ascending: true)
            
           if translationFolderArr.count == 0 {
               self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true).sorted(byKeyPath: "date", ascending: true)
            }
        }
        
        tableView.reloadData()
        
    }
    
    func tableViewReload(){
        translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.tableView.reloadData()
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if self.translationFolderArr.count != 0 {
//            for number1 in 0...translationFolderArr.count - 1 {
//                self.resultsArr.append(translationFolderArr[number1])
//            }
//
//            for number2 in self.resultsArr {
//                for number3 in 0...number2.results.count - 1 {
//                    let inputData = number2.results[number3].inputData
//                    let resultData = number2.results[number3].resultData
//                }
//            }
//        }
//    }
    
   
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.translationFolderArr.count == 0{
            self.label.text = "右上のボタンでフォルダーを作成しよう！"
            return ""
        } else {
            self.label.text = ""
            return "フォルダー 一覧"
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if translationFolderArr.count == 0 {
            tableView.isEditing = false
            editButton.setTitle("編集", for: .normal)
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
        return translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.numberOfLines = 0
//        セルに内容設定
//        cell.textLabel?.text = realmDataBaseArr[indexPath.row].folderName
            let translationFolderArr1 = self.translationFolderArr[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = translationFolderArr1.folderName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: translationFolderArr1.date)
        cell.detailTextLabel?.text = "作成日:\(dateString)"
        }
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
        
//        if self.number == 1 {
//            tableView.deselectRow(at: indexPath, animated: true)
//            number = 0
//            return
//
//        } else if number == 0 {
//
            var translationFolderArr = try! Realm().objects(TranslationFolder.self)
            
            self.folderNameString = translationFolderArr[indexPath.row].folderName
            
            print(indexPath.row)
            
            print("確認したい : \(folderNameString!)")
            
            
            print(try! Realm().objects(TranslationFolder.self))

            let predict = NSPredicate(format: "folderName == %@", folderNameString!)
            translationFolderArr =  translationFolderArr.filter(predict)
            
            print("確認11 \(translationFolderArr)")
            
        tableView.deselectRow(at: indexPath, animated: true)
                  
            if translationFolderArr[0].results.count != 0 {
                //        self.performSegue(withIdentifier: "ToHistory2", sender: nil)
                //        print("確認3 : \(self.folderNameString!)")
                let history2ViewController = self.storyboard!.instantiateViewController(withIdentifier: "History2ViewController") as! History2ViewController
                
                history2ViewController.folderNameString = folderNameString!
                
                self.present(history2ViewController, animated: true, completion: nil)
                
                number = 1
                
            } else {
                SVProgressHUD.show()
                SVProgressHUD.showError(withStatus: "'\(self.folderNameString!)' フォルダー内に保存されたデータがありません")
                number = 1
                
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
    
        
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        if let folderNameString = self.folderNameString {
    //
    //            let history2ViewController = segue.destination as! History2ViewController
    //            history2ViewController.folderNameString = folderNameString
    //
    //            print("確認8 : \(folderNameString)")
    //        }
    //    }
    
//}



    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    

