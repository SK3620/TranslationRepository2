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
    @IBOutlet private var textField: UITextField!

    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var label1: UILabel!

    @IBOutlet private var view1: UIView!

    private var reviewDate = [String]()
    private var folderName = [String]()
    private var content = [String]()
    private var memo = [String]()
    private var times = [String]()
    private var inputDate = [String]()

    private let realm = try! Realm()
    private var recordArr = try! Realm().objects(Record.self).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
    private var resultsArr: Results<Record>!

    private var datePicker: UIDatePicker = .init()

    var dateString: String!

    var tabBarController1: UITabBarController!

    var studyViewController: StudyViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.settingsForTableViewAndDatePicker()

        self.setDoneToolBarForTextField()

        self.setPlaceHolderForTextView()

        self.textField.layer.borderColor = UIColor.systemGray3.cgColor
        self.textField.layer.borderWidth = 2
        self.textField.layer.cornerRadius = 6

//        default settings
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        self.datePicker.date = formatter.date(from: dateString)!
    }

    private func settingsForTableViewAndDatePicker() {
        self.tableView.separatorColor = .gray
        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        self.tableView.layer.borderWidth = 2

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForReview", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.timeZone = NSTimeZone.local
        self.datePicker.locale = Locale.current
    }

    private func setPlaceHolderForTextView() {
        self.textField.attributedPlaceholder = NSAttributedString(string: "日付を入力してください",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    private func setDoneToolBarForTextField() {
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

        // retrive the data whose property 'nextReviewDate' is equal to enterd date in the textField
        let predicate = NSPredicate(format: "nextReviewDate == %@", dateString)
        self.resultsArr = self.recordArr.filter(predicate)

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

                self.label1.text = "\(dateString)に復習する内容はありません\n代わりに全データを設定した復習日の日付順に表示しています"
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
            self.label1.text = "全てのデータを設定した復習日の日付順に表示しています"
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        self.tableView.reloadData()
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.setStringOnTitle()

        self.settingsForNavigtionControllerAndBar()

        if self.recordArr.isEmpty != true {
            self.appendValuesToArrays()
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }

        if self.studyViewController == nil {
            self.view1.backgroundColor = .systemGray4
        } else {
            self.view1.backgroundColor = .white
        }
    }

    private func settingsForNavigtionControllerAndBar() {
        self.tabBarController1?.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = .systemGray5
        navigationController?.navigationBar.backgroundColor = .systemGray5
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(self.editButton(_:)))
        navigationItem.rightBarButtonItems = [editBarButtonItem]
    }

    private func setStringOnTitle() {
        let date = Date()
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateString = dateFomatter.string(from: date)
        title = "今日 \(dateString)"
    }

    private func appendValuesToArrays() {
        self.recordArr.forEach {
            self.reviewDate.append($0.nextReviewDate)
            self.times.append($0.times)
            self.folderName.append($0.folderName)
            self.content.append($0.number)
            self.memo.append($0.memo)
            self.inputDate.append($0.inputDate)
        }
        self.resultsArr = self.recordArr
        self.label1.text = "全てのデータを設定した復習日の日付順に表示しています"
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.label1.text == "全てのデータを設定した復習日の日付順に表示しています", self.textField.text == "", self.folderName.isEmpty {
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        return self.folderName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForReview

        cell.setData(self.reviewDate[indexPath.row], self.folderName[indexPath.row], self.content[indexPath.row], self.memo[indexPath.row], self.times[indexPath.row], self.inputDate[indexPath.row])

        self.determineIfItIsChecked(cell: cell, indexPath: indexPath)

        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tappedCheckMarkButton(_:)), for: .touchUpInside)

        return cell
    }

    private func determineIfItIsChecked(cell: CustomCellForReview, indexPath: IndexPath) {
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
    }

    @objc func tappedCheckMarkButton(_ sender: UIButton) {
        let result = self.resultsArr[sender.tag].isChecked
        switch result {
        case false:
            try! self.realm.write {
                resultsArr[sender.tag].isChecked = true
                realm.add(resultsArr, update: .modified)
            }
            SVProgressHUD.show()
            SVProgressHUD.showSuccess(withStatus: "復習が完了しました")
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            SVProgressHUD.dismiss(withDelay: 1.5)
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
                self.label1.text = "\(String(describing: self.dateString))に登録されたデータはありません\n代わりに全てのデータを設定した復習日の日付順に表示しています"
                self.resultsArr = self.recordArr
            }
            tableView.reloadData()
        }
    }

    @objc func editButton(_: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.isEditing = false
        } else {
            self.tableView.isEditing = true
        }
    }
}
