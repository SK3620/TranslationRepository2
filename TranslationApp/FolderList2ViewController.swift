//
//  FolderList2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/21.
//

import UIKit
import RealmSwift
import SVProgressHUD
import Alamofire





class FolderList2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
   
    var folderName: String!
    var sender_tag: Int!
    var inputData: String!
    var resultData: String!
    var inputAndResultData: String!
    
    var string = "保存先 : "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        label1.text = "保存先を選択してください"
        label2.text = string
        
        saveButton.isEnabled = false
        saveButton.layer.borderColor = UIColor.systemBlue.cgColor
        saveButton.layer.borderWidth = 1
        saveButton.layer.cornerRadius = 10
        
        

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        translationFolderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderList2Cell", for: indexPath)
        
//        セルに内容設定
        let realmDataBase = translationFolderArr[indexPath.row].folderName
        
        let date = translationFolderArr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.folderName = translationFolderArr[indexPath.row].folderName
       
        saveButton.isEnabled = true
        label2.text = string + folderName
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        SVProgressHUD.show()
        
        let predict = NSPredicate(format: "folderName == %@", self.folderName)
        self.translationFolderArr = self.realm.objects(TranslationFolder.self).filter(predict).sorted(byKeyPath: "date", ascending: true)
        
        let translation = Translation()
        translation.inputData = self.inputData
        translation.resultData = self.resultData
        translation.inputAndResultData = self.inputAndResultData
       
        let allTranslation = realm.objects(Translation.self)
                            if allTranslation.count != 0 {
                                translation.id = allTranslation.max(ofProperty: "id")! + 1
                            }
        try! Realm().write{
            translationFolderArr.first!.results.append(translation)
        }
        
        SVProgressHUD.showSuccess(withStatus: "'\(folderName!)'へ保存しました")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { () -> Void in
            SVProgressHUD.dismiss()
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    
    

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
