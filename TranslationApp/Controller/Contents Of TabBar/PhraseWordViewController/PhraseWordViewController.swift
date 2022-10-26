//
//  PhraseViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/18.
//

import UIKit
import RealmSwift
import ContextMenuSwift

class PhraseWordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
    
    
    
    
    let realm = try! Realm()
    let phraseWordArr = try! Realm().objects(PhraseWord.self).sorted(byKeyPath: "date", ascending: true)
//    入力した文章とその翻訳結果を格納する配列
    var inputDataList = [String]()
    var resultDataList = [String]()
    
    //    tabBarControllerクラスのインスタンスを格納する用の変数
    var tabBarController1: TabBarController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor.systemBlue
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomCellForPhraseWord", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        editButton.setTitle("編集", for: .normal)
        editButton.isEnabled = false
        tableView.isEditing = false
        
//        navigationbarのタイトルを設定
        if let tabBarController1 = self.tabBarController1 {
            tabBarController1.setBarButtonItem4()
            tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
//        phraseWordArrに値があれば、appendする。
        self.inputDataList = []
        self.resultDataList = []
        if self.phraseWordArr.count != 0 {
            editButton.isEnabled = true
            for number in 0...self.phraseWordArr.count - 1 {
                self.inputDataList.append(phraseWordArr[number].inputData)
                self.resultDataList.append(phraseWordArr[number].resultData)
                self.label1.text = ""
            }
        } else {
            label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if phraseWordArr.count == 0 {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForPhraseWord
        cell.setData1(self.inputDataList[indexPath.row], indexPath.row)
        
        //           タップされたセル内の星マークボタンのtagを設定
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        
        //         星マークが3種類のため、Boolではなく、Int型でswitch判定
        let isChecked = phraseWordArr[indexPath.row].isChecked
        switch isChecked {
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
            print("nil")
        }
        
        //　　　　文章タップで表示、非表示切り替えボタン
        //           label1の上に設置したボタン
        cell.displayButton1.tag = indexPath.row
        cell.displayButton1.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)
        //       　　　label2の上に設置したボタン
        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)
        
        let isDisplayed = phraseWordArr[indexPath.row].isDisplayed
        switch isDisplayed {
        case false:
            if indexPath.row == 0 {
                cell.label2.text = ""
                let image = UIImage(systemName: "hand.tap")
                cell.displayButton2.setImage(image, for: .normal)
                cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            } else if indexPath.row != 0 {
                cell.label2.text = ""
                cell.displayButton2.setImage(UIImage(), for: .normal)
                cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            }
        case true:
            cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            cell.displayButton2.setImage(UIImage(), for: .normal)
            cell.setData2(self.resultDataList[indexPath.row])
        }
        return cell
    }
    
    
    //　　　checkMarkButton(星マークボタン）タップ時
    @objc func tapCellButton(_ sender: UIButton){
        
        let isChecked = phraseWordArr[sender.tag].isChecked
        editButton.setTitle("編集", for: .normal)
        
        switch isChecked {
        case 0:
            try! Realm().write{
                phraseWordArr[sender.tag].isChecked = 1
                realm.add(phraseWordArr, update: .modified)
            }
        case 1:
            try! Realm().write{
                phraseWordArr[sender.tag].isChecked = 2
                realm.add(phraseWordArr, update: .modified)
            }
        case 2:
            try! Realm().write{
                phraseWordArr[sender.tag].isChecked = 0
                realm.add(phraseWordArr, update: .modified)
            }
            
        default:
            print("その他の値です")
        }
        
        tableView.reloadData()
    }
    
    
    //    文章タップで表示、非表示切り替えボタンタップ時
    @objc func tapDisplayButton(_ sender: UIButton){
        
        let isDisplayed = phraseWordArr[sender.tag].isDisplayed
        editButton.setTitle("編集", for: .normal)
        
        switch isDisplayed {
        case false:
            try! Realm().write{
                phraseWordArr[sender.tag].isDisplayed = true
                realm.add(phraseWordArr, update: .modified)
            }
        case true:
            try! Realm().write{
                phraseWordArr[sender.tag].isDisplayed = false
                realm.add(phraseWordArr, update: .modified)
            }
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
                self.realm.delete(self.phraseWordArr[indexPath.row])
                self.inputDataList.remove(at: indexPath.row)
                self.resultDataList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
        }
    }
    
    
    //    編集ボタンタップ時
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
        
    }
    
    
}



extension PhraseWordViewController: ContextMenuDelegate {
    
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
        
        switch index {
        case 0:
            self.tableView.isEditing = true
            self.editButton.setTitle("完了", for: .normal)
        case 1:
            setUIAlertController()
        default:
            print("他の値")
        }
        return true
    }
    
    
    //         コンテキストメニューが表示されたら呼ばれる
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("コンテキストメニュー表示されました")
    }
    //         コンテキストメニューが消えたら呼ばれる
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("コンテキストメニューが消えました")
    }
    
    
    func setUIAlertController(){
        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
            
            do {
                let realm = try Realm()
                try realm.write {
                    self.realm.delete(self.phraseWordArr)
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

