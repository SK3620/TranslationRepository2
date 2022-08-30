//
//  HistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
//    データ一覧を取得
    var realmDataBaseArr = try! Realm().objects(RealmDataBase.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.fillerRowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print("実行された")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmDataBaseArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        セルに内容設定
//        cell.textLabel?.text = realmDataBaseArr[indexPath.row].folderName
        let realmDataBase = realmDataBaseArr[indexPath.row]
        cell.textLabel?.text = realmDataBase.folderName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: realmDataBase.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

}
