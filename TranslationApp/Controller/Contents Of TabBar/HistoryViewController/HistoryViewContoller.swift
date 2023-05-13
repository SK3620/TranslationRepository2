//
//  RirekiViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import ContextMenuSwift
import RealmSwift
import SVProgressHUD
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var view1: UIView!

    @IBOutlet private var searchBar: UISearchBar!

    private var centerLabel: UILabel!

    private let realm = try! Realm()
    private var historyArr: Results<Histroy> = try! Realm().objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)

    private var inputDataCopy: String!
    private var resultDataCopy: String!

    var tabBarController1: TabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue

        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.enablesReturnKeyAutomatically = false

        // set done bar on keyboard
        self.setDoneToolbar()

        let nib = UINib(nibName: "CustomCellForHistory", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        let centerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        centerLabel.textColor = UIColor.systemOrange
        centerLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        centerLabel.textAlignment = .center
//        tableViewのbackgroundViewとしてラベルを表示
        self.tableView.backgroundView = centerLabel
        centerLabel.center = self.tableView.center
        centerLabel.numberOfLines = 0
        self.centerLabel = centerLabel
    }

    // set done bar on keyboard
    private func setDoneToolbar() {
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
        if self.tabBarController1 != nil {
            //        navigationbar settings
            self.navigationBarSettings()
        }

        self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        if self.historyArr.count == 0 {
            self.centerLabel.text = "翻訳して保存すると、翻訳履歴が表示されます"
//            self.editButton.isEnabled = false
        } else {
//            self.editButton.isEnabled = true
            self.centerLabel.text = ""
        }

//        文字列検索をしている場合
        if self.searchBar.text != "" {
            self.historyArr = self.historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        }

        self.tableView.reloadData()
    }

    // navigationbar settings
    private func navigationBarSettings() {
        // display "履歴" in title
        self.tabBarController1.setStringToNavigationItemTitle2()

        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

        // Install a button to create a folder in the upper right corner of the screen
        let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
        self.tabBarController1?.navigationItem.rightBarButtonItems = [self.setMenuBarButtonItem(), createFolderBarButtonItem]
    }

    // Display a menu bar with buttons for deleting part or all of the history
    private func setMenuBarButtonItem() -> UIBarButtonItem {
        let deleteSome = UIAction(title: "一部削除する", image: UIImage()) { [self] _ in
            self.tableView.isEditing = true
            // after the button for deleting part of the history is tapped, remove editBarButtonItem to display menu bar that is already contained in the Array rightBarButtonItems and install editDoneBarButtonItem only to finish editing tableView
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

    // editBarButtonItem which was inserted in the Array rightBarButtonItems
    @objc func tappedEditDoneBarButtonItem(_: UIBarButtonItem) {
        self.tableView.isEditing = false
        // remove editDoneBarButtonItem only to delete part of the history from array rightBarButtonItems and insert editBarButtonItem to display a menu bar again
        // every time the button for deleting part of the history is tapped, repeat these proceeses
        self.tabBarController1.navigationItem.rightBarButtonItems?.remove(at: 0)
        self.tabBarController1.navigationItem.rightBarButtonItems?.insert(self.setMenuBarButtonItem(), at: 0)
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        // call a method defined in the TabBarController class to show UIAlert and create a new folder
        self.tabBarController1?.createFolder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_: UISearchBar, textDidChange _: String) {
        self.search()
    }

    // do a string search
    private func search() {
        self.historyArr = self.historyArr.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")

        // If a string search is performed and no hits are found, display all data.
        if self.historyArr.count == 0 {
            self.historyArr = self.realm.objects(Histroy.self).sorted(byKeyPath: "date", ascending: true)
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        // if there is no history data
        if self.historyArr.count == 0 {
            tableView.isEditing = false
            self.centerLabel.text = "翻訳して保存すると、翻訳履歴が表示されます"
        } else {
            // if there is history data
            tableView.isEditing = false
            self.centerLabel.text = ""
        }
        return self.historyArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForHistory

        let historyArr = historyArr[indexPath.row]
        let inputData = historyArr.inputData
        let resultData = historyArr.resultData
        let date = historyArr.date
        let dateString = self.getDate(date: date)

        cell.setData(inputData, resultData, dateString, indexPath.row + 1)

        // set a tag for button and determine the cell of the tapped button
        cell.copyButton.addTarget(self, action: #selector(self.tappedCopyButton(_:)), for: .touchUpInside)
        cell.copyButton.tag = indexPath.row

        return cell
    }

    private func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: date)
        return dateString
    }

    // a process to copy
    @objc func tappedCopyButton(_ sender: UIButton) {
        self.tableView.isEditing = false
        UIPasteboard.general.string = self.historyArr[sender.tag].inputData + "\n" + "\n" + self.historyArr[sender.tag].resultData
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete data from Realm dataBase
            try! self.realm.write {
                self.realm.delete(self.historyArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
        }
    }

    // UIAlet for deleting all hitory data
    private func setUIAlertController() {
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in print("キャンセルボタンがタップされた。")
        })
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            do {
                let realm = try Realm()
                try realm.write {
                    self.historyArr.forEach {
                        realm.delete($0)
                    }
                }
            } catch {
                print("エラー")
            }
            self.historyArr = self.realm.objects(Histroy.self)
            self.centerLabel.text = "翻訳して保存すると、翻訳履歴が表示されます"
            self.tableView.reloadData()
        })
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
}
