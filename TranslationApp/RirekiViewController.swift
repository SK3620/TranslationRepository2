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

class RirekiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
  
    @IBOutlet weak var rirekiTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
   
    
    let realm = try! Realm()
    var historyArr: Results<Histroy> = try! Realm().objects(Histroy.self).sorted(byKeyPath: "date2", ascending: true)
    
    var intArr = [Int]()
    var inputDataCopy: String!
    var resultDataCopy: String!
    var tabBarController1: TabBarController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rirekiTableView.delegate = self
        rirekiTableView.dataSource = self
        rirekiTableView.separatorColor = .systemBlue
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.enablesReturnKeyAutomatically = false
        
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton =  UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
        

        let nib = UINib(nibName: "CustomCellTableViewCell", bundle: nil)
        rirekiTableView.register(nib, forCellReuseIdentifier: "CustomCell")
        print("登録されてます")
        
        // Do any additional setup after loading the view.
    }
    
    @objc func doneButtonTapped(sender: UIButton){
        self.searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
       
        rirekiTableView.isEditing = false
        editButton.setTitle("編集", for: .normal)
        
        
        self.tabBarController1.setBarButtonItem2()
        tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.historyArr = realm.objects(Histroy.self).sorted(byKeyPath: "date2", ascending: true)
        if historyArr.count == 0 {
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
            label1.text = ""
        }
        
        if searchBar.text != "" {
            self.historyArr =  historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        }
        
        self.rirekiTableView.reloadData()
        
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        }
    
    func  searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search()
    }
    
    func search(){
        self.historyArr  = historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        
        if historyArr.count == 0 {
            self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date2", ascending: true)
        }
        
        rirekiTableView.reloadData()
        }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellTableViewCell
        
        let historyArr2 = historyArr[indexPath.row]
        
        let inputData2 = historyArr2.inputData2
        let resultData2 = historyArr2.resultData2
        
        let date2 = historyArr2.date2
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: date2)
        
        cell.setData(inputData2, resultData2, dateString, indexPath.row + 1)
        
//        buttonにタグを設定　tapされたボタンのcellを判定 addTargetを追加
        cell.copyButton.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        cell.copyButton.tag = indexPath.row
      
        return cell
    }
    
    @objc func tapCellButton(_ sender: UIButton){
//        外部引数_にはたっぷされたボタン自体が入る そいつがsenderでsenderはUIButtonが持つtagプロパティを利用する
        rirekiTableView.isEditing = false
        UIPasteboard.general.string = self.historyArr[sender.tag].inputData2 + "\n" + "\n" + self.historyArr[sender.tag].resultData2
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyArr.count == 0 {
            rirekiTableView.isEditing = false
            editButton.isEnabled = false
            editButton.setTitle("編集", for: .normal)
            label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
        } else {
            editButton.isEnabled = true
            rirekiTableView.isEditing = false
            label1.text = ""
        }
        return self.historyArr.count
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

    @IBAction func button1Action(_ sender: Any) {
        
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in  for number1 in 1...self.historyArr.count{
            var number2 = number1
            number2 = 0
            self.intArr.append(number2)
            print(self.intArr)
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
            
            self.rirekiTableView.reloadData()
            print("リロードされた")
            
        })
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
        })
        
        alert.addAction(delete)
        alert.addAction(cencel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func editButtonAction(_ sender: Any) {

        if self.editButton.titleLabel!.text! == "完了" {
            rirekiTableView.isEditing = false
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

extension RirekiViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        print("コンテキストメニューの", index, "番目のセルが選択された！")
    print("そのセルには", item.title, "というテキストが書いてあるよ!")
        
        switch index {
        case 0:
            self.rirekiTableView.isEditing = true
            self.editButton.setTitle("完了", for: .normal)
        case 1:
           setUIAlertController()
        default:
            print("他の値")
            
        }
        
        //サンプルではtrueを返していたのでとりあえずtrueを返してみる
        return true
        
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
    }
    
    func setUIAlertController(){
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in  for number1 in 1...self.historyArr.count{
            var number2 = number1
            number2 = 0
            self.intArr.append(number2)
            print(self.intArr)
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
            self.rirekiTableView.reloadData()
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
    
    
    //
    //        for number in 0...self.historyArr.count - 1{
    //            try! realm.write{
    //                print("確認 : \(number)")
    //                self.realm.delete(self.historyArr[number])
    //                print("削除")
    //            }
    //        }
    
    
    
    //
    //                    try! realm.write{
    //                        for number in 0...2 {
    //                            self.realm.delete(self.historyArr[number])
    //                        }
    //                    }
    //
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
     }
     */
    


