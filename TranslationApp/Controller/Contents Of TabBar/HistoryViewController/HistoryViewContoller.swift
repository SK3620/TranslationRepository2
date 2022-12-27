//
//  RirekiViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import Alamofire
import ContextMenuSwift
import RealmSwift
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var view1: UIView!
    @IBOutlet var label1: UILabel!
    @IBOutlet var searchBar: UISearchBar!

    let realm = try! Realm()
    var historyArr: Results<Histroy> = try! Realm().objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)

    var intArr = [Int]()
    var inputDataCopy: String!
    var resultDataCopy: String!
    var tabBarController1: TabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue

        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.enablesReturnKeyAutomatically = false

//        キーボードに完了バー設置
        self.setDoneToolbar()

        let nib = UINib(nibName: "CustomCellForHistory", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

//    キーボードに完了ボタン設置
    func setDoneToolbar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTapped(sender _: UIButton) {
        self.searchBar.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        //        navigationbarの設定
        if let tabBarController1 = tabBarController1 {
            self.tabBarController1.setStringToNavigationItemTitle2()
            tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
//            let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self,
//                                                    action: #selector(self.tappedEditBarButtonItem(_:)))
            let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
            self.tabBarController1?.navigationItem.rightBarButtonItems = [self.setMenuBarButtonItem(), createFolderBarButtonItem]
        }

        self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        if self.historyArr.count == 0 {
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
//            self.editButton.isEnabled = false
        } else {
//            self.editButton.isEnabled = true
            self.label1.text = ""
        }

//        文字列検索をしている場合
        if self.searchBar.text != "" {
            self.historyArr = self.historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        }

        self.tableView.reloadData()
    }

    func setMenuBarButtonItem() -> UIBarButtonItem {
        let deleteSome = UIAction(title: "一部削除する", image: UIImage()) { [self] _ in
            self.tableView.isEditing = true
            self.tabBarController1?.navigationItem.rightBarButtonItems?.remove(at: 0)
            let editDoneBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(tappedEditDoneBarButtonItem(_:)))
            self.tabBarController1.navigationItem.rightBarButtonItems?.insert(editDoneBarButtonItem, at: 0)
        }
        let deleteAll = UIAction(title: "全て削除する", image: UIImage()) { _ in
            self.setUIAlertController()
        }
        let menu = UIMenu(title: "", children: [deleteSome, deleteAll])
        let menuBarItem = UIBarButtonItem(title: "編集", menu: menu)
        return menuBarItem
    }

    @objc func tappedEditDoneBarButtonItem(_: UIBarButtonItem) {
        self.tableView.isEditing = false
        self.tabBarController1.navigationItem.rightBarButtonItems?.remove(at: 0)
        self.tabBarController1.navigationItem.rightBarButtonItems?.insert(self.setMenuBarButtonItem(), at: 0)
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        self.tabBarController1?.createFolder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_: UISearchBar, textDidChange _: String) {
        self.search()
    }

//    文字列検索をする
    func search() {
        self.historyArr = self.historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")

//        文字列検索をして何もヒットしなければ、全てのデータを表示する
        if self.historyArr.count == 0 {
            self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        }

        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.historyArr.count == 0 {
            tableView.isEditing = false
//            self.editButton.isEnabled = false
//            self.editButton.setTitle("編集", for: .normal)
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
        } else {
//            self.editButton.isEnabled = true
            tableView.isEditing = false
            self.label1.text = ""
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
        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:)), for: .touchUpInside)
        cell.copyButton.tag = indexPath.row

        return cell
    }

//    コピーする
    @objc func tappedCopyButton(_ sender: UIButton) {
        self.tableView.isEditing = false
        UIPasteboard.general.string = self.historyArr[sender.tag].inputData + "\n" + "\n" + self.historyArr[sender.tag].resultData
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! self.realm.write {
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

    func createContextMenu() {
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
    func contextMenuDidSelect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        print("コンテキストメニューの", index, "番目のセルが選択された！")
        print("そのセルには", item.title, "というテキストが書いてあるよ!")

        switch index {
        case 0:
            self.tableView.isEditing = true
//            self.editButton.setTitle("完了", for: .normal)
        case 1:
            self.setUIAlertController()
        default:
            print("nil")
        }
        return true
    }

    func contextMenuDidDeselect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt _: Int) {}

    func contextMenuDidAppear(_: ContextMenu) {
        print("メニューが表示されました")
    }

    func contextMenuDidDisappear(_: ContextMenu) {
        print("メニューが閉じられました")
    }

    func setUIAlertController() {
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in print("キャンセルボタンがタップされた。")
        })
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
//            for number1 in 1...self.historyArr.count{
//            var number2 = number1
//            number2 = 0
//            self.intArr.append(number2)
//        }
            do {
//                try realm.write{
//                    for number3 in self.intArr{
//                        realm.delete(self.historyArr[number3])
//                    }
                let realm = try Realm()
                try realm.write {
                    self.historyArr.forEach {
                        realm.delete($0)
                    }
                }
            } catch {
                print("エラー")
            }
            self.intArr = []
            self.historyArr = self.realm.objects(Histroy.self)
            self.label1.text = "翻訳して保存すると、翻訳履歴が表示されます"
            self.tableView.reloadData()

        })

        alert.addAction(cancel)
        alert.addAction(delete)

        present(alert, animated: true, completion: nil)
    }
}
