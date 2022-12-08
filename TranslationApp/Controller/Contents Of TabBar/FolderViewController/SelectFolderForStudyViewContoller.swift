//
//  FolderList2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/21.
//

import Alamofire
import RealmSwift
import SVProgressHUD
import UIKit

class SelectFolderForStudyViewContoller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var label2: UILabel!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!

    let realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    //    以下五つは、studyViewControllerから画面遷移時に、値が渡される。
    var folderName: String!
    var sender_tag: Int!
    var inputData: String!
    var resultData: String!
    var inputAndResultData: String!

    var string = "保存先 : "

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarAppearence()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.label2.text = self.string

        self.saveButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    func setNavigationBarAppearence() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
        self.navigationController?.navigationBar.standardAppearance = appearence
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.translationFolderArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let folderNameString = self.translationFolderArr[indexPath.row].folderName

        let date = self.translationFolderArr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString: String = formatter.string(from: date)

        //        セクション番号で条件分岐
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = folderNameString
            //        複数行可能
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = "作成日:\(dateString)"
        }
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.folderName = self.translationFolderArr[indexPath.row].folderName

        self.saveButton.isEnabled = true
        self.label2.text = self.string + self.folderName
    }

    @IBAction func saveButton(_: Any) {
        SVProgressHUD.show()

        let predict = NSPredicate(format: "folderName == %@", folderName)
        self.translationFolderArr = self.realm.objects(TranslationFolder.self).filter(predict).sorted(byKeyPath: "date", ascending: true)

        let translation = Translation()
        translation.inputData = self.inputData
        translation.resultData = self.resultData
        translation.inputAndResultData = self.inputAndResultData

        let allTranslation = self.realm.objects(Translation.self)
        if allTranslation.count != 0 {
            translation.id = allTranslation.max(ofProperty: "id")! + 1
        }
        try! Realm().write {
            translationFolderArr.first!.results.append(translation)
        }

        SVProgressHUD.showSuccess(withStatus: "'\(self.folderName!)'へ保存しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func backButton(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}
