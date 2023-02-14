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
    @IBOutlet var tableView: UITableView!

    @IBOutlet private var label2: UILabel!

    @IBOutlet private var saveButton: UIBarButtonItem!

    private let realm = try! Realm()
    private var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

    // values are passed to these below 5 variables from StudyVC when the screen transition to self is performed
    var folderName: String!
    var sender_tag: Int!
    var inputData: String!
    var resultData: String!
    var inputAndResultData: String!
    var secondMemo: String!

    private var string = "保存先 : "

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarAppearence()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.label2.text = self.string

        self.saveButton.isEnabled = false
    }

    private func setNavigationBarAppearence() {
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

        // Conditional branching by section number
        if indexPath.section == 0 {
            cell.imageView?.image = UIImage(systemName: "folder")
            cell.textLabel?.text = folderNameString
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

    // save the inputData and resultData of the tapped cell in StudyVC to realm database
    @IBAction func saveButton(_: Any) {
        let predicate = NSPredicate(format: "folderName == %@", folderName)
        self.translationFolderArr = self.realm.objects(TranslationFolder.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        let translation = Translation()
        translation.inputData = self.inputData
        translation.resultData = self.resultData
        translation.inputAndResultData = self.inputAndResultData
        translation.secondMemo = self.secondMemo

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
