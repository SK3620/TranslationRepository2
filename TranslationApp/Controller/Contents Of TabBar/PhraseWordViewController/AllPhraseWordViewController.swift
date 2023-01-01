//
//  AllPhraseWordViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/02.
//

import RealmSwift
import UIKit

// the function in SecondPhraseWordViewController is almost the same as the one in the PhraseWordViewController
// retrive all data whose 'isChekced' property is 0,1,2
class AllPhraseWordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var label1: UILabel!

    private let realm = try! Realm()
    private var phraseWordArr: Results<PhraseWord>!

    private var inputDataList = [String]()
    private var resultDataList = [String]()

    var tabBarController1: TabBarController?

    var pagingPhraseWordViewController: PagingPhraseWordViewController?

    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.systemBlue
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
        if self.tabBarController1!.navigationItem.rightBarButtonItems?.count == 2 {
            self.tabBarController1?.navigationItem.rightBarButtonItems?.remove(at: 0)
        }
        self.tabBarController1?.navigationItem.rightBarButtonItems?.insert(editBarButtonItem, at: 0)

        if self.studyViewController != nil {
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = []
            self.pagingPhraseWordViewController!.navigationItem.rightBarButtonItems = [editBarButtonItem]
        }
        self.tableView.isEditing = false

        self.appendValuesToArrays()

        self.tableView.reloadData()
    }

    @objc func tappedEditBarButtonItem(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }

    func appendValuesToArrays() {
        self.inputDataList = []
        self.resultDataList = []

        self.phraseWordArr = try! Realm().objects(PhraseWord.self).sorted(byKeyPath: "date", ascending: true)
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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.inputDataList.isEmpty {
            self.label1.text = "お気に入りの単語・フレーズを追加しよう！"
        }
        return self.inputDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForPhraseWord

        cell.setData1(self.inputDataList[indexPath.row], indexPath.row)

        // use Int type instead of Bool type since ther are three types of star-mark
        self.determineIfItIsBookeMarkedAndChangeStarIcon(cell: cell, indexPath: indexPath)

        self.determineIfItIsDisplayed(cell: cell, indexPath: indexPath)

        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tappedCheckMarkButton(_:)), for: .touchUpInside)

        cell.displayButton1.tag = indexPath.row
        cell.displayButton1.addTarget(self, action: #selector(self.tappedDisplayButton(_:)), for: .touchUpInside)
        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(self.tappedDisplayButton(_:)), for: .touchUpInside)

        return cell
    }

    private func determineIfItIsBookeMarkedAndChangeStarIcon(cell: CustomCellForPhraseWord, indexPath: IndexPath) {
        let isChecked = self.phraseWordArr[indexPath.row].isChecked
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
        case true:
            cell.displayButton2.setImage(UIImage(), for: .normal)
            cell.setData2(self.resultDataList[indexPath.row])
        }
    }

    @objc func tappedCheckMarkButton(_ sender: UIButton) {
        let isChecked = self.phraseWordArr[sender.tag].isChecked
        switch isChecked {
        case 0:
            try! Realm().write {
                phraseWordArr[sender.tag].isChecked = 1
                realm.add(phraseWordArr, update: .modified)
            }
        case 1:
            try! Realm().write {
                phraseWordArr[sender.tag].isChecked = 2
                realm.add(phraseWordArr, update: .modified)
            }
        case 2:
            try! Realm().write {
                phraseWordArr[sender.tag].isChecked = 0
                realm.add(phraseWordArr, update: .modified)
            }
        default:
            print("その他の値です")
        }
        self.appendValuesToArrays()
        self.tableView.reloadData()
    }

    //    文章タップで表示、非表示切り替えボタンタップ時
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
