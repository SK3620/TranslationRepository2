//
//  ReviewViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/30.
//

import RealmSwift
import SVProgressHUD
import UIKit

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var textField: UITextField!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var label1: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var label3: UILabel!
    @IBOutlet var view1: UIView!

    var reviewDate = [String]()
    var folderName = [String]()
    var content = [String]()
    var memo = [String]()
    var times = [String]()
    var inputDate = [String]()

    let realm = try! Realm()
    var recordArr = try! Realm().objects(Record.self).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
    var resultsArr: Results<Record>!

    var datePicker: UIDatePicker = .init()
    var dateString: String!
    var tabBarController1: UITabBarController!
    var studyViewController: StudyViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = .gray

        let nib = UINib(nibName: "CustomCellForReview", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        self.textField.layer.borderColor = UIColor.gray.cgColor
        self.textField.layer.borderWidth = 2
        self.textField.layer.cornerRadius = 6

        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        self.tableView.layer.borderWidth = 2.5

        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = NSTimeZone.local
        self.datePicker.locale = Locale.current
        self.setDoneToolBarForTextField()
//        デフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        self.datePicker.date = formatter.date(from: dateString)!

        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    func setDoneToolBarForTextField() {
        // 決定バーの生成
        let toolbar4 = UIToolbar()
        toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done4))
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(self.cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        self.textField.inputView = self.datePicker
        self.textField.inputAccessoryView = toolbar4
    }

    @objc func done4() {
        self.textField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        let dateString = formatter.string(from: self.datePicker.date)
        self.textField.text = dateString

        let predict = NSPredicate(format: "nextReviewDate == %@", dateString)
        self.resultsArr = self.recordArr.filter(predict)

        self.reviewDate = []
        self.times = []
        self.folderName = []
        self.content = []
        self.memo = []
        self.inputDate = []

        if self.recordArr.isEmpty != true {
            if self.resultsArr.count != 0 {
                self.resultsArr.forEach {
                    self.reviewDate.append($0.nextReviewDate)
                    self.times.append($0.times)
                    self.folderName.append($0.folderName)
                    self.content.append($0.number)
                    self.memo.append($0.memo)
                    self.inputDate.append($0.inputDate)
                }
                self.label1.text = "\(dateString)に復習する内容があります"
            } else {
                self.recordArr.forEach {
                    self.reviewDate.append($0.nextReviewDate)
                    self.times.append($0.times)
                    self.folderName.append($0.folderName)
                    self.content.append($0.number)
                    self.memo.append($0.memo)
                    self.inputDate.append($0.inputDate)
                }
                self.resultsArr = self.recordArr

                self.label1.text = "\(dateString)に復習する内容はありません\n代わりに全データを日付順に表示しています"
            }
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        self.tableView.reloadData()
    }

    @objc func cancel4() {
        self.textField.endEditing(true)
        self.textField.text = ""

        self.reviewDate = []
        self.folderName = []
        self.content = []
        self.memo = []
        self.times = []
        self.inputDate = []

        if self.recordArr.isEmpty != true {
            self.recordArr.forEach {
                self.reviewDate.append($0.nextReviewDate)
                self.times.append($0.times)
                self.folderName.append($0.folderName)
                self.content.append($0.number)
                self.memo.append($0.memo)
                self.inputDate.append($0.inputDate)
            }
            self.resultsArr = self.recordArr
            self.label1.text = "全てのデータを日付順に表示しています"
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        self.tableView.reloadData()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        let date = Date()
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateString = dateFomatter.string(from: date)

        self.tabBarController1?.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "次回復習日・内容 \(dateString)"
        navigationController?.navigationBar.barTintColor = .systemGray4
        navigationController?.navigationBar.backgroundColor = .systemGray4
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.editButton(_:)))
        navigationItem.rightBarButtonItems = [editBarButtonItem]

        if self.recordArr.isEmpty != true {
            self.recordArr.forEach {
                self.reviewDate.append($0.nextReviewDate)
                self.times.append($0.times)
                self.folderName.append($0.folderName)
                self.content.append($0.number)
                self.memo.append($0.memo)
                self.inputDate.append($0.inputDate)
            }
            self.resultsArr = self.recordArr
            self.label1.text = "全てのデータを日付順に表示しています"
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        if self.studyViewController == nil {
            self.backButton.isHidden = true
            self.backButton.isEnabled = false
            self.editButton.isEnabled = false
            self.editButton.isHidden = true
            self.label3.text = ""
            self.editButton.setTitle("", for: .normal)
            self.view1.backgroundColor = .systemGray4
        } else {
            self.label3.text = "次回復習日・内容 \(dateString)"
            self.editButton.setTitle("編集", for: .normal)
            self.view1.backgroundColor = .white
            self.backButton.setTitle("戻る", for: .normal)
            self.backButton.isEnabled = true
            self.backButton.isHidden = false
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.label1.text == "全てのデータを日付順に表示しています", self.textField.text == "", self.folderName.isEmpty {
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        return self.folderName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForReview
        cell.setData(self.reviewDate[indexPath.row], self.folderName[indexPath.row], self.content[indexPath.row], self.memo[indexPath.row], self.times[indexPath.row], self.inputDate[indexPath.row])
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tapCheckMarkButton(_:)), for: .touchUpInside)

        let isChecked = self.resultsArr[indexPath.row].isChecked
        switch isChecked {
        case false:
            let image = UIImage(systemName: "checkmark.circle")
            cell.checkMarkButton.setImage(image, for: .normal)
            cell.checkMarkButton.tintColor = UIColor.gray
        case true:
            let image = UIImage(systemName: "checkmark.circle.fill")
            cell.checkMarkButton.setImage(image, for: .normal)
            cell.checkMarkButton.tintColor = UIColor.systemGreen
        }
        return cell
    }

    @objc func tapCheckMarkButton(_ sender: UIButton) {
        let result = self.resultsArr[sender.tag].isChecked
        switch result {
        case false:
            try! self.realm.write {
                resultsArr[sender.tag].isChecked = true
                realm.add(resultsArr, update: .modified)
            }
            SVProgressHUD.show()
            SVProgressHUD.showSuccess(withStatus: "復習が完了しました")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
                SVProgressHUD.dismiss()
            }
        case true:
            try! self.realm.write {
                resultsArr[sender.tag].isChecked = false
                realm.add(resultsArr, update: .modified)
            }
        }
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! self.realm.write {
                self.realm.delete(self.resultsArr[indexPath.row])
                self.folderName.remove(at: indexPath.row)
                self.content.remove(at: indexPath.row)
                self.times.remove(at: indexPath.row)
                self.reviewDate.remove(at: indexPath.row)
                self.memo.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if self.resultsArr.count == 0, self.recordArr.count == 0 {
                self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
            } else if self.resultsArr.count == 0 {
                self.label1.text = "\(String(describing: self.dateString))に登録されたデータはありません\n代わりに全てのデータを日付順に表示しています"
                self.resultsArr = self.recordArr
            }
            tableView.reloadData()
        }
    }

    @objc func editButton(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
            self.editButton.setTitle("編集", for: .normal)
        } else {
            self.tableView.isEditing = true
            self.editButton.setTitle("完了", for: .normal)
        }
    }

    @IBAction func editButton1(_: Any) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
            self.editButton.setTitle("編集", for: .normal)
        } else {
            self.tableView.isEditing = true
            self.editButton.setTitle("完了", for: .normal)
        }
    }

    @IBAction func backButton(_: Any) {
        dismiss(animated: true)
    }
}
