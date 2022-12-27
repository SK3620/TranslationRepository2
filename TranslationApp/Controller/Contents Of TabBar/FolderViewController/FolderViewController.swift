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
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var label: UILabel!

    var folderNameString: String?
    var resultsArr = [TranslationFolder]()
    var tabBarController1: TabBarController!

    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder> = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        let speak = Speak()
        speak.playInputData = false
//        入力した文章を音声読み上げ
        speak.playResultData = true
//        翻訳結果を音声読み上げ
        try! Realm().write {
            self.realm.add(speak, update: .modified)
        }

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        //        何も入力されていなくてもreturnキー押せるようにする
        self.searchBar.enablesReturnKeyAutomatically = false

        // キーボードに完了のツールバーを作成
        self.setDoneOnKeyBoard()
    }

//    検索時の完了のボタンタップ時
    @objc func doneButtonTaped(sender _: UIButton) {
        self.searchBar.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

//        StudyViewControllerで音声再生されていたら、音声停止する
        AVSpeechSynthesizer().stopSpeaking(at: .immediate)

//        フォルダーがない場合、画面に表示
        self.label.text = "右上のボタンでフォルダーを作成しよう！"
//        self.editButton.setTitle("編集", for: .normal)
//        self.tableView.isEditing = false

        navigationController!.setNavigationBarHidden(true, animated: false)
        //        navigationbarの設定
        if let tabBarController1 = tabBarController1 {
            tabBarController1.setStringToNavigationItemTitle1()
            tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
            let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self,
                                                    action: #selector(self.tappedEditBarButtonItem(_:)))
            let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
            self.tabBarController1?.navigationItem.rightBarButtonItems = [editBarButtonItem, createFolderBarButtonItem]
        }

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        if self.translationFolderArr.count == 0 {
//            self.editButton.isEnabled = false
        }

        self.tableView.reloadData()
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
//        検索欄に何もなければ
        if self.searchBar.text == "" {
            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

        } else {
//            あれば、
            self.translationFolderArr = self.translationFolderArr.filter("folderName CONTAINS '\(self.searchBar.text!)'")
//            検索欄に入力があり、さらにtranslationFolderArrが空なら、全て表示する
            if self.translationFolderArr.count == 0 {
                self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
            }
        }

        self.tableView.reloadData()
    }

    func tableViewReload() {
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.translationFolderArr.count == 0 {
            tableView.isEditing = false
            self.label.text = "右上のボタンでフォルダーを作成しよう！"
//            self.editButton.setTitle("編集", for: .normal)
//            self.editButton.isEnabled = false
        } else {
            self.label.text = ""
//            self.editButton.isEnabled = true
        }
        return self.translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0

//        セルに内容設定
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.textLabel?.text = self.translationFolderArr[indexPath.row].folderName

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"

        let dateString: String = formatter.string(from: self.translationFolderArr[indexPath.row].date)
        cell.detailTextLabel?.text = "作成日:\(dateString)"

        return cell
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! self.realm.write {
                self.realm.delete(self.translationFolderArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
        }
    }

//    セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var translationFolderArr = try! Realm().objects(TranslationFolder.self)

        self.folderNameString = self.translationFolderArr[indexPath.row].folderName

        let predict = NSPredicate(format: "folderName == %@", folderNameString!)
        translationFolderArr = translationFolderArr.filter(predict)

        tableView.deselectRow(at: indexPath, animated: true)

//        resultsに何も値があれば、フォルダー名をhitory2ViewControllerへ渡す+画面遷移
        if translationFolderArr[0].results.count != 0 {
            let studyViewContoller = storyboard!.instantiateViewController(withIdentifier: "StudyViewController") as! StudyViewController

            studyViewContoller.folderNameString = self.folderNameString!

            performSegue(withIdentifier: "ToStudyViewController", sender: self.folderNameString)
//                number = 1

        } else {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "'\(self.folderNameString!)' フォルダー内に保存されたデータがありません")
//                number = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { () in
                SVProgressHUD.dismiss()
            }
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
//            self.editButton.setTitle("編集", for: .normal)
        } else {
            self.tableView.isEditing = true
//            self.editButton.setTitle("完了", for: .normal)
        }
    }

    func setDoneOnKeyBoard() {
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
