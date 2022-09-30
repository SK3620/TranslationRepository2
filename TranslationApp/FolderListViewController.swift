//
//  FolderListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/31.
//

import UIKit
import RealmSwift

class FolderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    

    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    
    var number: Int = 0
    var folderNameString: String = ""
    var string: String = "保存先 : "
    var translateViewController: TranslateViewController!
    
    let realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.folderNameLabel.text = self.string
        
        let borderColor = UIColor.gray.cgColor
        let borderColor1 = UIColor.white.cgColor
        
        listTableView.layer.borderColor = borderColor1
//        listTableView.layer.borderWidth = 2.5
//        listTableView.layer.cornerRadius = 10
        
        confirmButton.layer.borderWidth = 2.5
        confirmButton.layer.borderColor = borderColor
        confirmButton.layer.cornerRadius = 10

        backButton.layer.borderWidth = 2.5
        backButton.layer.borderColor = borderColor
        backButton.layer.cornerRadius = 10
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
       
        
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.folderNameLabel.text = self.string
        
        if translationFolderArr.count == 0 {
            label.text = "フォルダーを作成して下さい"
            label.textColor = UIColor.orange
            self.confirmButton.isEnabled = false
        } else {
            label.text = "保存先を選択して下さい"
        self.confirmButton.isEnabled = false
        }
    }
    
//    セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    セクションのタイトル
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "保存先一覧"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translationFolderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderListCell", for: indexPath)
        
//        セルに内容設定
        let realmDataBase = translationFolderArr[indexPath.row].folderName
        
        let date = translationFolderArr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: date)
    
//        セクション番号で条件分岐
        if indexPath.section == 0 {
            
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = realmDataBase
//        複数行可能
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "作成日:\(dateString)"
            
           
        }
        
        return cell
    }
    
//    セルが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        タップされたfolderName
//        if self.number == 0 {
        var folderName = translationFolderArr[indexPath.row].folderName
        self.folderNameLabel.text! = self.string + folderName
        self.confirmButton.isEnabled = true
            self.folderNameString = folderName
//            self.number += 1
//            print("DEBUG : \(self.folderNameString)")
//        } else if self.number == 1 {
////            tableView.deselectRow(at: indexPath, animated: true)
////            self.confirmButton.isEnabled = false
//            let folderName = translationFolderArr[indexPath.row].folderName
//            self.folderNameLabel.text! += folderName
//            self.folderNameString = folderName
//            self.number = 0
//        }
        
    }

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func selectButton(_ sender: Any) {
        
//        let navigationController = self.presentingViewController as! UINavigationController
////        let navigationController = tabBarController.viewControllers![1] as! UINavigationController
//        let viewController = navigationController.viewControllers[0] as! ViewController
//
//        let tabBarController = viewController.presentedViewController as! UITabBarController
//
//        let navigationController2 = tabBarController.viewControllers![1] as! UINavigationController
//
//        let translateViewController = navigationController2.viewControllers[0] as! TranslateViewController
//
        
        translateViewController.textStringForButton2 = self.folderNameString

        self.dismiss(animated: true)
    }

}
