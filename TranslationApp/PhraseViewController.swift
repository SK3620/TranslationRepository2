//
//  PhraseViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/18.
//

import UIKit
import RealmSwift
import ContextMenuSwift

class PhraseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
//    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    
    let realm = try! Realm()
    let record2Arr = try! Realm().objects(Record2.self).sorted(byKeyPath: "date5", ascending: true)
    var inputDataList = [String]()
    var resultDataList = [String]()
    
    var tabBarController1: TabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .gray
        
//        self.searchBar.backgroundImage = UIImage()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.layer.borderColor = UIColor.gray.cgColor
//        tableView.layer.borderWidth = 0.5
      
//        searchBar.delegate = self
//        searchBar.enablesReturnKeyAutomatically = false
        
        let nib = UINib(nibName: "CustomPhraseWordViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomPhraseWordCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        label1.text = "お気に入りの単語・フレーズを追加しよう！"
       
        
        editButton.setTitle("編集", for: .normal)
        tableView.isEditing = false
        
//        let navigationController = self.navigationController as! NavigationForPhraseControllerViewController
//        print(navigationController)
       
        if let tabBarController1 = self.tabBarController1 {
        tabBarController1.setBarButtonItem4()
        }
        
  
        
        self.inputDataList = []
        self.resultDataList = []
        editButton.isEnabled = false
        
        if self.record2Arr.count != 0 {
            editButton.isEnabled = true
            for number in 0...self.record2Arr.count - 1 {
                self.inputDataList.append(record2Arr[number].inputData3)
                self.resultDataList.append(record2Arr[number].resultData3)
                self.label1.text = ""
            }
        }
        self.tableView.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if record2Arr.count == 0 {
            editButton.isEnabled = false
            editButton.setTitle("編集", for: .normal)
            tableView.isEditing = false
        } else {
            editButton.isEnabled = true
            tableView.isEditing = false
          
        }
        
        if self.inputDataList.isEmpty{
            label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
        
        return self.inputDataList.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPhraseWordCell", for: indexPath) as! CustomPhraseWordViewCell
           cell.setData1(self.inputDataList[indexPath.row], indexPath.row)
           
           cell.checkMarkButton.tag = indexPath.row
           cell.checkMarkButton.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        
           
           let result = record2Arr[indexPath.row].isChecked
           
           switch result {
           case 0:
               let image0 = UIImage(systemName: "star")
               cell.checkMarkButton.setImage(image0, for: .normal)
               
           case 1:
               let image1 = UIImage(systemName: "star.leadinghalf.filled")
               cell.checkMarkButton.setImage(image1, for: .normal)
               
           case 2:
               let image2 = UIImage(systemName: "star.fill")
               cell.checkMarkButton.setImage(image2, for: .normal)
               
           default:
               print("その他の値です")
           }
           
           cell.displayButton0.tag = indexPath.row
           cell.displayButton0.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)

           cell.displayButton.tag = indexPath.row
           cell.displayButton.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)
           
           
           
           let result1 = record2Arr[indexPath.row].isDisplayed
           
           switch result1 {
           case 0:
               cell.displayButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
               if indexPath.row == 0 {
                   cell.label2.text = ""
               let image = UIImage(systemName: "hand.tap")
               cell.displayButton.setImage(image, for: .normal)
               } else if indexPath.row != 0 {
                   let image = UIImage()
                   cell.displayButton.setImage(image, for: .normal)
                   cell.label2.text = ""
               }
           case 1:
               cell.displayButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
               let image1 = UIImage()
               cell.displayButton.setImage(image1, for: .normal)
               cell.setData2(self.resultDataList[indexPath.row])
           default:
               print("その他の値です")
           }
           
           print(cell.label2.text!)
           
           return cell
       }
    
    
    @objc func tapCellButton(_ sender: UIButton){
        print("タップされた")
        let result = record2Arr[sender.tag].isChecked
        editButton.setTitle("編集", for: .normal)
        
        switch result {
        case 0:
            try! Realm().write{
                record2Arr[sender.tag].isChecked = 1
                realm.add(record2Arr, update: .modified)
            }
        case 1:
            try! Realm().write{
                record2Arr[sender.tag].isChecked = 2
                realm.add(record2Arr, update: .modified)
            }
        case 2:
            try! Realm().write{
                record2Arr[sender.tag].isChecked = 0
                realm.add(record2Arr, update: .modified)
            }
       
        default:
            print("その他の値です")
        }
        
        tableView.reloadData()
    }
    

    
    @objc func tapDisplayButton(_ sender: UIButton){
        print("タップされた")
        let result = record2Arr[sender.tag].isDisplayed
        editButton.setTitle("編集", for: .normal)
        
        switch result {
        case 0:
            try! Realm().write{
                record2Arr[sender.tag].isDisplayed = 1
                realm.add(record2Arr, update: .modified)
            }
        case 1:
            try! Realm().write{
                record2Arr[sender.tag].isDisplayed = 0
                realm.add(record2Arr, update: .modified)
            }
        default:
            print("その他の値です")
        }
        
        tableView.reloadData()
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
    
//    @IBAction func deleteButton(_ sender: Any) {
//
//        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
//        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
//
//            do {
//                let realm = try Realm()
//            try realm.write {
//                self.realm.delete(self.record2Arr)
//                self.inputDataList = []
//                self.resultDataList = []
//            }
//
//            self.button.isEnabled  = false
//
//            self.tableView.reloadData()
//            } catch {
//                print("エラー")
//            }
//        })
//
//            let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
//            })
//
//            alert.addAction(delete)
//            alert.addAction(cencel)
//
//            self.present(alert, animated: true, completion: nil)
//        }
    
    @IBAction func editButtonAction(_ sender: Any) {
        
        if self.editButton.titleLabel!.text! == "完了" {
            tableView.isEditing = false
            editButton.setTitle("編集", for: .normal)
            return
        }
//        コンテキストメニューの内容を作成
        let delete = ContextMenuItemWithImage(title: "一部削除する", image: UIImage())
        let deleteAll = ContextMenuItemWithImage(title: "全て削除する", image: UIImage())
       
//        表示するアイテムを決定
        CM.items = [delete, deleteAll]
//        表示します
        CM.showMenu(viewTargeted: self.view1, delegate: self, animated: true)
        
//        if tableView.isEditing == true {
//            tableView.isEditing = false
//        } else {
//            tableView.isEditing = true
//        }
        
    }
    
    
}

extension PhraseViewController: ContextMenuDelegate {
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
    }
    
//    コンテキストメニューが表示された時の挙動を設定
    
    
//    コンテキストメニューの選択肢が選択された時に実行される
//            - Parameters:
//                - contextMenu: そのコンテキストメニューだと思われる
//                - cell: **選択されたコンテキストメニューの**セル
//                - targetView: コンテキストメニューの発生源のビュー
//                - item: 選択されたコンテキストのアイテム(タイトルとか画像とかが入ってる)
//                - index: **選択されたコンテキストのアイテムの**座標
//            - Returns: よくわからない(多分成功したらtrue...?
//         */
        func contextMenuDidSelect(_ contextMenu: ContextMenu,
                                  cell: ContextMenuCell,
                                  targetedView: UIView,
                                  didSelect item: ContextMenuItem,
                                  forRowAt index: Int) -> Bool {
            
            print("コンテキストメニューの", index, "番目のセルが選択された！")
        print("そのセルには", item.title, "というテキストが書いてあるよ!")
            
            switch index {
            case 0:
                self.tableView.isEditing = true
                self.editButton.setTitle("完了", for: .normal)
            case 1:
               setUIAlertController()
            default:
                print("他の値")
                
            }
            
            //サンプルではtrueを返していたのでとりあえずtrueを返してみる
            return true
            
        }
        
        /**
         コンテキストメニューが表示されたら呼ばれる
         */
        func contextMenuDidAppear(_ contextMenu: ContextMenu) {
            print("コンテキストメニューが表示された!")
        }
        
        /**
         コンテキストメニューが消えたら呼ばれる
         */
        func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
            print("コンテキストメニューが消えた!")
        }
    
    
    func setUIAlertController(){
        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
            
            do {
                let realm = try Realm()
                try realm.write {
                    self.realm.delete(self.record2Arr)
                    self.inputDataList = []
                    self.resultDataList = []
                }
                
                self.tableView.reloadData()
                self.editButton.setTitle("編集", for: .normal)
            } catch {
                print("エラー")
            }
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
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

