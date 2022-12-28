//
//  HistoryViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Alamofire
import AVFAudio
import AVFoundation
import RealmSwift
import SVProgressHUD
import UIKit

class FolderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!

    @IBOutlet private var searchBar: UISearchBar!

    @IBOutlet private var label: UILabel!

    private var folderNameString: String?

    private var resultsArr = [TranslationFolder]()

    var tabBarController1: TabBarController!

    private let realm = try! Realm()
    private var translationFolderArr: Results<TranslationFolder> = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        // wrtie to Speak realm database in advance
        let speak = Speak()
        speak.playInputData = false
        // if it reads out input text or not
        speak.playResultData = true
        // if it reads out result text or not
        try! Realm().write {
            self.realm.add(speak, update: .modified)
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()

        // Allow the return key to be pressed even if nothing is typed.
        self.searchBar.enablesReturnKeyAutomatically = false

        // キーボードに完了のツールバーを作成
        self.setDoneOnKeyBoard()
    }

    // when done button tapped
    @objc func doneButtonTaped(sender _: UIButton) {
        self.searchBar.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

        // Stop audio if it is playing in StudyViewController
        AVSpeechSynthesizer().stopSpeaking(at: .immediate)

//       if there are no folders, display
        self.label.text = "右上のボタンでフォルダーを作成しよう！"

        navigationController!.setNavigationBarHidden(true, animated: false)
        //        navigationbar settings
        self.navigationBarSettings()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.tableView.reloadData()
    }

    private func navigationBarSettings() {
        if let tabBarController1 = tabBarController1 {
            // display "フォルダー" in title
            tabBarController1.setStringToNavigationItemTitle1()
            tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

            let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self,
                                                    action: #selector(self.tappedEditBarButtonItem(_:)))
            let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
            self.tabBarController1?.navigationItem.rightBarButtonItems = [editBarButtonItem, createFolderBarButtonItem]
        }
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        self.tabBarController1?.createFolder()
    }

    @objc func tappedEditBarButtonItem(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }

//     検索ボタン押下時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_: UISearchBar, textDidChange _: String) {
        //　if there are no characters in the seachBar, return
        if self.searchBar.text == "" {
            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
            self.tableView.reloadData()
            return
        }
        // if there are any characters in the search bar
        self.translationFolderArr = self.translationFolderArr.filter("folderName CONTAINS '\(self.searchBar.text!)'")

        // if there are any characters entered in the search bar and translationFolderArr is empty, display all the folderNames
        if self.translationFolderArr.count == 0 {
            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.translationFolderArr.count == 0 {
            tableView.isEditing = false
            self.label.text = "右上のボタンでフォルダーを作成しよう！"
        } else {
            self.label.text = ""
        }
        return self.translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let date = self.translationFolderArr[indexPath.row].date
        let dateString = self.getDate(date: date)
        cell.detailTextLabel?.text = "作成日:\(dateString)"
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.textLabel?.text = self.translationFolderArr[indexPath.row].folderName
        return cell
    }

    private func getDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // when the delete button is tapped
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! self.realm.write {
                self.realm.delete(self.translationFolderArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.tableViewReload()
        }
    }

    private func tableViewReload() {
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.tableView.reloadData()
    }

    // when the cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var translationFolderArr = try! Realm().objects(TranslationFolder.self)
        self.folderNameString = self.translationFolderArr[indexPath.row].folderName
        let predicate = NSPredicate(format: "folderName == %@", folderNameString!)
        translationFolderArr = translationFolderArr.filter(predicate)

        tableView.deselectRow(at: indexPath, animated: true)

//        If results has any value, pass the folder name to hitory2ViewController and perform screen transition
        if translationFolderArr[0].results.count != 0 {
            let studyViewContoller = storyboard!.instantiateViewController(withIdentifier: "StudyViewController") as! StudyViewController
            studyViewContoller.folderNameString = self.folderNameString!
            performSegue(withIdentifier: "ToStudyViewController", sender: self.folderNameString)
        } else {
            // if it doesn't have any value
            SVProgressHUD.showError(withStatus: "'\(self.folderNameString!)' フォルダー内に保存されたデータがありません")
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToStudyViewController" {
            let studyViewController = segue.destination as! StudyViewController
            studyViewController.folderNameString = sender as! String
            studyViewController.tabBarController1 = self.tabBarController1
        }
    }

    @IBAction func editButtonAction(_: Any) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }

    // install done bar on keyboard
    private func setDoneOnKeyBoard() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }
}

// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
