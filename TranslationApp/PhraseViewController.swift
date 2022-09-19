//
//  PhraseViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/18.
//

import UIKit
import RealmSwift

class PhraseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    
    let realm = try! Realm()
    let record2Arr = try! Realm().objects(Record2.self).sorted(byKeyPath: "date5", ascending: true)
    var inputDataList = [String]()
    var resultDataList = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2.5
        button.layer.cornerRadius = 10
        
        button.isEnabled = false

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        button.isEnabled = false
        
        self.inputDataList = []
        self.resultDataList = []
        
        if self.record2Arr.count != 0 {
            self.button.isEnabled = true
            for number in 0...self.record2Arr.count - 1 {
                self.inputDataList.append(record2Arr[number].inputData3)
                self.resultDataList.append(record2Arr[number].resultData3)
                
            }
        }
        self.tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inputDataList.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           cell.textLabel?.text = "\(indexPath.row + 1): " + self.inputDataList[indexPath.row]
           cell.detailTextLabel?.text = self.resultDataList[indexPath.row]
           cell.textLabel?.numberOfLines = 0
           cell.detailTextLabel?.numberOfLines = 0
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
                self.realm.delete(self.record2Arr[indexPath.row])
                self.inputDataList.remove(at: indexPath.row)
                self.resultDataList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
            
            do {
                let realm = try Realm()
            try realm.write {
                self.realm.delete(self.record2Arr)
                self.inputDataList = []
                self.resultDataList = []
            }
            
            self.button.isEnabled  = false
            
            self.tableView.reloadData()
            } catch {
                print("エラー")
            }
        })
        
            let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
            })
            
            alert.addAction(delete)
            alert.addAction(cencel)
            
            self.present(alert, animated: true, completion: nil)
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

