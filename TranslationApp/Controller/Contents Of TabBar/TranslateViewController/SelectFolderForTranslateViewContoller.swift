//
//  FolderListViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/31.
//

import RealmSwift
import UIKit

class SelectFolderForTranslateViewContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var folderNameLabel: UILabel!
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var backButton: UIButton!

    var folderNameString: String = ""
    var translateViewController: TranslateViewController!
    var string: String = "保存先 : "
    let realm = try! Realm()
    let translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.folderNameLabel.text = self.string

        self.selectButton.layer.borderWidth = 1
        self.selectButton.layer.borderColor = UIColor.systemBlue.cgColor
        self.selectButton.layer.cornerRadius = 10

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue
        self.tableView.layer.borderColor = UIColor.white.cgColor

        if self.translationFolderArr.count == 0 {
            self.label.text = "フォルダーを作成して下さい"
            self.label.textColor = UIColor.orange
            self.selectButton.isEnabled = false
        } else {
            self.label.text = "保存先を選択して下さい"
            self.selectButton.isEnabled = false
        }
    }

//    セクション数
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //        セルに内容設定
        let folderName = self.translationFolderArr[indexPath.row].folderName

        let date = self.translationFolderArr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString: String = formatter.string(from: date)

        cell.imageView?.image = UIImage(systemName: "folder")
        cell.textLabel?.text = folderName

        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "作成日:\(dateString)"

        return cell
    }

    //    セルが選択された時
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = self.translationFolderArr[indexPath.row].folderName
        self.folderNameLabel.text! = self.string + folderName
        self.selectButton.isEnabled = true
        self.folderNameString = folderName
    }

    @IBAction func backButton(_: Any) {
        dismiss(animated: true)
    }

    @IBAction func selectButton(_: Any) {
        self.translateViewController.folderNameString = self.folderNameString
        self.translateViewController.setStringForButton2()

        dismiss(animated: true)
    }
}
