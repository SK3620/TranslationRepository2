//
//  RirekiViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import UIKit
import RealmSwift
import ContextMenuSwift
import Alamofire

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var historyArr: Results<Histroy> = try! Realm().objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
    
    var intArr = [Int]()
    var inputDataCopy: String!
    var resultDataCopy: String!
    var tabBarController1: TabBarController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .systemBlue
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.enablesReturnKeyAutomatically = false
        
//        キーボードに完了バー設置
       setDoneToolbar()
        
        let nib = UINib(nibName: "CustomCellForHistory", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }
    
//    キーボードに完了ボタン設置
    func setDoneToolbar(){
        let doneToolbar = UIToolbar()
               doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
               let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
               let doneButton =  UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTapped))
               doneToolbar.items = [spacer, doneButton]
               self.searchBar.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonTapped(sender: UIButton){
        self.searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.editButton.setTitle("編集", for: .normal)
        
//        navigationBarのタイトルを設定
        self.tabBarController1.setBarButtonItem2()
        tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.historyArr = realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        if historyArr.count == 0 {
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
            label1.text = ""
        }
        
//        文字列検索をしている場合
        if searchBar.text != "" {
            self.historyArr =  historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        }
        
        self.tableView.reloadData()
        
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        }
    
    func  searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search()
    }
    
//    文字列検索をする
    func search(){
        self.historyArr  = historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        
//        文字列検索をして何もヒットしなければ、全てのデータを表示する
        if historyArr.count == 0 {
            self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        }
        
        tableView.reloadData()
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyArr.count == 0 {
            tableView.isEditing = false
            editButton.isEnabled = false
            editButton.setTitle("編集", for: .normal)
            label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
        } else {
            editButton.isEnabled = true
            tableView.isEditing = false
            label1.text = ""
        }
        return self.historyArr.count
      }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForHistory
        
        let historyArr = historyArr[indexPath.row]
        
        let inputData = historyArr.inputData
        let resultData = historyArr.resultData
        
        let date2 = historyArr.date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: date2)
        
        cell.setData(inputData, resultData, dateString, indexPath.row + 1)
        
//        buttonにタグを設定　tapされたボタンのcellを判定 addTargetを追加
        cell.copyButton.addTarget(self, action: #selector(tappedCopyButton(_:)), for: .touchUpInside)
        cell.copyButton.tag = indexPath.row
      
        return cell
    }
    
//    コピーする
    @objc func tappedCopyButton(_ sender: UIButton){
        tableView.isEditing = false
        UIPasteboard.general.string = self.historyArr[sender.tag].inputData + "\n" + "\n" + self.historyArr[sender.tag].resultData
    }


    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! realm.write  {
                self.realm.delete(self.historyArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
           tableView.reloadData()
        }
    }

//    @IBAction func button1Action(_ sender: Any) {
//
//        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
//        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in  for number1 in 1...self.historyArr.count{
//            var number2 = number1
//            number2 = 0
//            self.intArr.append(number2)
//            print(self.intArr)
//        }
//
//            do {
//                let realm = try Realm()
//                try realm.write{
//                    for number3 in self.intArr{
//                        realm.delete(self.historyArr[number3])
//                    }
//                }
//            } catch {
//                print("エラー")
//            }
//            self.intArr = []
//            self.historyArr = self.realm.objects(Histroy.self)
//
//            self.tableView.reloadData()
//            print("リロードされた")
//
//        })
//        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
//        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
//        })
//
//        alert.addAction(delete)
//        alert.addAction(cencel)
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
    
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



extension HistoryViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        print("コンテキストメニューの", index, "番目のセルが選択された！")
    print("そのセルには", item.title, "というテキストが書いてあるよ!")
        
        switch index {
        case 0:
            self.tableView.isEditing = true
            self.editButton.setTitle("完了", for: .normal)
        case 1:
           setUIAlertController()
        default:
            print("nil")
            
        }
        return true
    }
    
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("メニューが表示されました")
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("メニューが閉じられました")
    }
    
    
    func setUIAlertController(){
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
            for number1 in 1...self.historyArr.count{
            var number2 = number1
            number2 = 0
            self.intArr.append(number2)
        }
            do {
                let realm = try Realm()
                try realm.write{
                    for number3 in self.intArr{
                        realm.delete(self.historyArr[number3])
                    }
                }
            } catch {
                print("エラー")
            }
            self.intArr = []
            self.historyArr = self.realm.objects(Histroy.self)
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
            self.tableView.reloadData()
            print("リロードされた")
            
        })
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
        })
        
        alert.addAction(delete)
        alert.addAction(cencel)
        
        self.present(alert, animated: true, completion: nil)
    }
}
    
    
   
