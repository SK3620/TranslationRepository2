//
//  PhraseViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/18.
//

import Parchment
import RealmSwift
import SVProgressHUD
import UIKit

class PhraseWordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var view1: UIView!

    @IBOutlet private var label1: UILabel!

    private let realm = try! Realm()
    private var phraseWordArr: Results<PhraseWord>!

    //   an array that stores entered sentences and its translated sentences
    private var inputDataList = [String]()
    private var resultDataList = [String]()

    var tabBarController1: TabBarController?

    var pagingPhraseWordViewController: PagingPhraseWordViewController?

    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let nib = UINib(nibName: "CustomCellForPhraseWord", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        if self.studyViewController != nil {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.tappedEditBarButtonItem(_:)))

        // If rightBarButtonItems contains two items, editBarButtonItem and createFolderBarButtonItem, remove the former.
        if self.tabBarController1!.navigationItem.rightBarButtonItems?.count == 2 {
            self.tabBarController1?.navigationItem.rightBarButtonItems?.remove(at: 0)
        }
        self.tabBarController1?.navigationItem.rightBarButtonItems?.insert(editBarButtonItem, at: 0)

        // a process to be called when the screen transition to self from studyViewController is performed
        if self.studyViewController != nil {
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = []
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = [editBarButtonItem]
        }
        self.tableView.isEditing = false

        self.appendValuesToArrays()

        self.tableView.reloadData()
    }

    override func viewDidDisappear(_: Bool) {
        super.viewDidDisappear(true)
        if self.studyViewController == nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    @objc func tappedEditBarButtonItem(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }

    // append values to inputDataList and resultDataList
//    retrive the data whose 'isChecked' property is 0 and to append them to the arrays
    private func appendValuesToArrays() {
        self.inputDataList = []
        self.resultDataList = []
        self.phraseWordArr = try! Realm().objects(PhraseWord.self).sorted(byKeyPath: "date", ascending: true).filter("isChecked == 0")
        if self.phraseWordArr.count != 0 {
            self.phraseWordArr.forEach {
                self.inputDataList.append($0.inputData)
                self.resultDataList.append($0.resultData)
            }
            self.label1.text = ""
        } else {
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
    }

    @objc func tappedBackBarButtonItem(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.inputDataList.isEmpty {
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
        return self.inputDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForPhraseWord

        cell.setData1(self.inputDataList[indexPath.row], indexPath.row)

        let image = UIImage(systemName: "star")
        cell.checkMarkButton.setImage(image, for: .normal)

        // determine if the resultData is being displayed or not
        self.determineIfItIsDisplayed(cell: cell, indexPath: indexPath)

        //        Set the tag for the star-mark button in the tapped cell
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tappedCheckMarkButton(_:)), for: .touchUpInside)

        //        Button to toggle display/hide by tapping text
        // a button placed above the label1
        cell.displayButton1.tag = indexPath.row
        cell.displayButton1.addTarget(self, action: #selector(self.tappedDisplayButton(_:)), for: .touchUpInside)
        //       　a button placed above the label2
        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(self.tappedDisplayButton(_:)), for: .touchUpInside)

        return cell
    }

    private func determineIfItIsDisplayed(cell: CustomCellForPhraseWord, indexPath: IndexPath) {
        let isDisplayed = self.phraseWordArr[indexPath.row].isDisplayed
        switch isDisplayed {
        case false:
            if indexPath.row == 0 {
                cell.label2.text = ""
                let image = UIImage(systemName: "hand.tap")
                cell.displayButton2.setImage(image, for: .normal)
            } else if indexPath.row != 0 {
                cell.label2.text = ""
                cell.displayButton2.setImage(UIImage(), for: .normal)
            }
            cell.centerLine.backgroundColor = .clear
        case true:
            cell.displayButton2.setImage(UIImage(), for: .normal)
            cell.setData2(self.resultDataList[indexPath.row])
            cell.centerLine.backgroundColor = .systemGray5
        }
    }

    // called when a checkmark (star-mark) button is tapped
    @objc func tappedCheckMarkButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "登録", message: "'星0.5'へ登録しますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let register = UIAlertAction(title: "登録", style: .default) { _ in

            let isChecked = self.phraseWordArr[sender.tag].isChecked
            switch isChecked {
            case 0:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 1
                    self.realm.add(self.phraseWordArr, update: .modified)
                }
            case 1:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 2
                    self.realm.add(self.phraseWordArr, update: .modified)
                }
            case 2:
                try! Realm().write {
                    self.phraseWordArr[sender.tag].isChecked = 0
                    self.realm.add(self.phraseWordArr, update: .modified)
                }
            default:
                print("その他の値です")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.appendValuesToArrays()
                self.tableView.reloadData()
                SVProgressHUD.showSuccess(withStatus: "登録完了")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        }
        alert.addAction(cancel)
        alert.addAction(register)
        present(alert, animated: true, completion: nil)
    }

    // switch display and non-display of the resultData in the tapped cell
    @objc func tappedDisplayButton(_ sender: UIButton) {
        let isDisplayed = self.phraseWordArr[sender.tag].isDisplayed
        switch isDisplayed {
        case false:
            try! Realm().write {
                phraseWordArr[sender.tag].isDisplayed = true
                realm.add(phraseWordArr, update: .modified)
            }
        case true:
            try! Realm().write {
                phraseWordArr[sender.tag].isDisplayed = false
                realm.add(phraseWordArr, update: .modified)
            }
        }
        self.appendValuesToArrays()
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // a process to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! self.realm.write {
                self.realm.delete(self.phraseWordArr[indexPath.row])
                self.inputDataList.remove(at: indexPath.row)
                self.resultDataList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.appendValuesToArrays()
            tableView.reloadData()
        }
    }
}
