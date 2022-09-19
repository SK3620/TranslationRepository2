//
//  HistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import RealmSwift
import SVProgressHUD

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    var folderNameString: String?
    var number: Int = 0
    
    let realm = try! Realm()
//    データ一覧を取得
    var translationFolderArr: Results<TranslationFolder> = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    func printMethod(){
        print("プリントメソッドが実行された")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
        print("実行された")
        
        self.number = 0
    }

    func tableViewReload(){
        translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.tableView.reloadData()
    }
    
   
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "フォルダー 一覧　 (左スワイプで削除)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.section == 0 {
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
    

