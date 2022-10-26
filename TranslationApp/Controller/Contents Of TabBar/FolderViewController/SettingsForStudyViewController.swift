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

    let realm = try! Realm()
    let speak = Speak()
    var indexPath_row: Int?
    var indexPathArr: [IndexPath] = [IndexPath(row: 3, section: 0), IndexPath(row: 4, section: 0)]
    var menuArr: [String] = ["単語・フレーズ", "学習記録", "メモ", "太字を再生", "小文字を再生", "閉じる"]
    var delegate: SettingsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        navigationController?.navigationBar.barTintColor = .systemGray6
        navigationController?.navigationBar.backgroundColor = .systemGray6
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
        tableView.deselectRow(at: indexPath, animated: true)

        dismiss(animated: true, completion: nil)

        self.delegate.tappedSettingsItem(indexPath: indexPath)

        if indexPath.row == 3 {
            self.showSVProgressHUD("太文字を音声再生します")

            let speak = Speak()

            try! Realm().write {
                speak.playInputData = true
                speak.playResultData = false
                realm.add(speak, update: .modified)
                print(speak)
            }

        } else if indexPath.row == 4 {
            self.showSVProgressHUD("小文字を音声再生します")

            try! Realm().write {
                speak.playInputData = false
                speak.playResultData = true
                realm.add(speak, update: .modified)
            }
        }
    }

    func showSVProgressHUD(_ string: String) {
        SVProgressHUD.show()
        SVProgressHUD.showSuccess(withStatus: string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
            SVProgressHUD.dismiss()
        }
    }

    func setImage(_ string: String, _ cell: UITableViewCell) {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .default)
        cell.imageView?.image = UIImage(systemName: string, withConfiguration: config)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
