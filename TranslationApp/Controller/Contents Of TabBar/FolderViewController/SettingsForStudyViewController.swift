//
//  SettingsViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/12.
//

import RealmSwift
import SVProgressHUD
import UIKit

class SettingsForStudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    private let realm = try! Realm()

    private let speak = Speak()

    var indexPath_row: Int?

    var delegate: SettingsDelegate!

    private var menuArr: [String] = ["お気に入り", "学習記録", "メモ", "太字を再生", "細字を再生", "閉じる"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.navigationBarSettings()
    }

    private func navigationBarSettings() {
        navigationController?.navigationBar.barTintColor = .systemGray5
        navigationController?.navigationBar.backgroundColor = .systemGray5
        title = "メニュー"
        navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor.black,
        ]
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.menuArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.menuArr[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        // delegate method
        // specify the information of the indexPath of the tapped cell as a parameter, and then delegate a process to studyViewController when tapeed
        self.delegate.tappedSettingsItem(indexPath: indexPath)

        if indexPath.row == 3 {
            // play resultData (translated characters) in the opend cell when tapped
            self.playResultData()
        } else if indexPath.row == 4 {
            // not play resultData but inputData
            self.playInputData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func playResultData() {
        try! Realm().write {
            self.speak.playInputData = true
            self.speak.playResultData = false
            realm.add(speak, update: .modified)
        }
        SVProgressHUD.showSuccess(withStatus: "太文字を音声再生します")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    private func playInputData() {
        try! Realm().write {
            self.speak.playInputData = false
            self.speak.playResultData = true
            realm.add(speak, update: .modified)
        }
        SVProgressHUD.showSuccess(withStatus: "小文字を音声再生します")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }
}
