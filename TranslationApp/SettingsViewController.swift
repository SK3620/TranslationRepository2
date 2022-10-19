//
//  SettingsViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/12.
//

import UIKit
import SVProgressHUD
import RealmSwift



class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var delegate: SettingsDelegate!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    let speak = Speak()
    var indexPath_row: Int?
    var indexPathArr: [IndexPath] = [IndexPath(row: 3, section: 0), IndexPath(row: 4, section: 0)]
    var menuArr: [String] = ["単語・フレーズ", "学習記録", "メモ", "太字を音声再生", "小文字を音声再生", "閉じる"]
    var delegate: SettingsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationController?.navigationBar.barTintColor = .systemGray6
        self.navigationController?.navigationBar.backgroundColor = .systemGray6
        self.title = "メニュー"
        self.navigationController?.navigationBar.titleTextAttributes = [
//文字の色
            .foregroundColor: UIColor.black
            ]
        
       
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.menuArr[indexPath.row]
        
        
//        switch self.indexPath_row {
//        case 3:
//            if indexPath.row == 3 {
//                setImage("checkmark", cell)
//            } else {
//                cell.imageView?.image = UIImage()
//            }
//        case 4:
//            if indexPath.row == 4 {
//                setImage("checkmark", cell)
//            } else {
//                cell.imageView?.image = UIImage()
//            }
//        default:
//            print("nil")
//        }
     
        
//        if indexPath.row == 3 && self.indexPath_row == 3 {
//            setImage("checkmark", cell)
//            print("画像実行")
//        } else {
//            cell.imageView?.image = UIImage()
//        }
//
//        if indexPath.row == 4 && self.indexPath_row == 4 {
//            setImage("checkmark", cell)
//        } else {
//            cell.imageView?.image = UIImage()
//        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        self.dismiss(animated: true, completion: nil)

        
        delegate.tappedSettingsItem(indexPath: indexPath)
        
        if indexPath.row == 3 {
            showSVProgressHUD("太文字を音声再生します")
            
            let speak = Speak()
            
            
            try! Realm().write{
                speak.playInputData = "on"
                speak.playResultData = "off"
                realm.add(speak, update: .modified)
                print(speak)
            }
           
        } else if indexPath.row == 4 {
            showSVProgressHUD("小文字を音声再生します")
            
            
            
            try! Realm().write{
                speak.playInputData = "off"
                speak.playResultData = "on"
                realm.add(speak, update: .modified)
            }
        }
        
        
        
//        if indexPath.row == 3 {
//            self.indexPath_row = 3
//            print("3")
//            tableView.reloadData()
//        } else if indexPath.row == 4 {
//            self.indexPath_row = 4
//            print("4")
//            tableView.reloadData()
//        }
    }
    
    func showSVProgressHUD(_ string: String){
        SVProgressHUD.show()
        SVProgressHUD.showSuccess(withStatus: string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { () -> Void in
            SVProgressHUD.dismiss()
        })
    }
    
    func setImage(_ string: String, _ cell: UITableViewCell){
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .default)
        cell.imageView?.image = UIImage(systemName: string, withConfiguration: config)
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
