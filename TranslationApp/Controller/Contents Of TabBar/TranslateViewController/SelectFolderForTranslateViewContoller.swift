//
//  FolderListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/31.
//

import UIKit
import RealmSwift

class SelectFolderForTranslateViewContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    
    var folderNameString: String = ""
    var translateViewController: TranslateViewController!
    var string: String = "保存先 : "
    let realm = try! Realm()
    let translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.folderNameLabel.text = self.string
        
        selectButton.layer.borderWidth = 1
        selectButton.layer.borderColor = UIColor.systemBlue.cgColor
        selectButton.layer.cornerRadius = 10
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .systemBlue
        tableView.layer.borderColor = UIColor.white.cgColor
        
        if translationFolderArr.count == 0 {
            label.text = "フォルダーを作成して下さい"
            label.textColor = UIColor.orange
            self.selectButton.isEnabled = false
        } else {
            label.text = "保存先を選択して下さい"
        self.selectButton.isEnabled = false
        }
    }
    

    
//    セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translationFolderArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        
        //        セルに内容設定
        let folderName = translationFolderArr[indexPath.row].folderName
        
        let date = translationFolderArr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString: String = formatter.string(from: date)
        
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.textLabel?.text = folderName
      
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "作成日:\(dateString)"
        
        return cell
    }


    //    セルが選択された時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = translationFolderArr[indexPath.row].folderName
        self.folderNameLabel.text! = self.string + folderName
        self.selectButton.isEnabled = true
        self.folderNameString = folderName
    }

    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func selectButton(_ sender: Any) {
        
        translateViewController.folderNameString = self.folderNameString
        translateViewController.setStringForButton2()

        self.dismiss(animated: true)
    }
    
    

}
