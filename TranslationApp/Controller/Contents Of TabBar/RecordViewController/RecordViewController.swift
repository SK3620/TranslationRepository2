//
//  RecordViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15./Users/suzukikenta/Library/Developer/Xcode/DerivedData
//

import Alamofire
import CalculateCalendarLogic
import FSCalendar
import RealmSwift
import SVProgressHUD
import UIKit

class RecordViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var fscalendar: FSCalendar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var label1: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var reviewButton: UIButton!

    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)

    var recordArrFilter: Results<Record>!
    var recordArrFilter2: Record!
    //　　　"yyyyMMdd"タップされたString型の日付を格納
    var dateString: String = ""
//    "\(year).\(month).\(day)"タップされたString型の日付を格納
    var dateString2: String = ""
    var tabBarController1: TabBarController!
    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addButton.isEnabled = false

        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        self.tableView.layer.borderWidth = 2.5

        self.fscalendar.delegate = self
        self.fscalendar.dataSource = self

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .gray

        let nib = UINib(nibName: "CustomCellForRecord", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"

        if self.tabBarController1 != nil, studyViewController == nil {
            self.tabBarController1.setBarButtonItem3()
            self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
        }

        navigationController?.setNavigationBarHidden(true, animated: false)

        if let studyViewController = studyViewController {
            studyViewController.SetTabBarController1()
        }
        self.tableView.reloadData()
        self.fscalendar.reloadData()
    }


    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        if let studyViewController = studyViewController {
            studyViewController.SetTabBarController1()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"

        if self.recordArrFilter != nil {
            return self.recordArrFilter.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForRecord

        if self.recordArrFilter.isEmpty {
            self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"
        } else {
            self.label1.text = ""
        }

        if self.recordArrFilter != nil {
            cell.setData(self.recordArrFilter[indexPath.row])

            let result = self.recordArrFilter[indexPath.row].isChecked
            switch result {
            case false:
                cell.label6.text = "(復習未完了)"
                cell.label6.textColor = .systemRed
                cell.checkMarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                cell.checkMarkButton.tintColor = UIColor.systemGray
            case true:
                cell.label6.text = "(復習完了)"
                cell.label6.textColor = .systemGreen
                cell.checkMarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                cell.checkMarkButton.tintColor = UIColor.systemGreen
            }
        }

        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tapCheckMarkButton2(_:)), for: .touchUpInside)

        return cell
    }

    @objc func tapCheckMarkButton2(_ sender: UIButton) {
        let result = self.recordArrFilter[sender.tag].isChecked
        switch result {
        case false:
            try! self.realm.write {
                recordArrFilter[sender.tag].isChecked = true
                realm.add(recordArrFilter, update: .modified)
                SVProgressHUD.show()
                SVProgressHUD.showSuccess(withStatus: "復習が完了しました")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { () in
                    SVProgressHUD.dismiss()
                }
            }
        case true:
            try! self.realm.write {
                recordArrFilter[sender.tag].isChecked = false
                realm.add(recordArrFilter, update: .modified)
            }
        }

        self.tableView.reloadData()
    }

    //    選択された日付を取得する　日付がタップされた時の処理
    //    選択された日付はdate変数に格納される
    func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        self.addButton.isEnabled = true

        self.reviewButton.setTitle("次回復習日・内容を確認する", for: .normal)

        //        このdate変数をCalendarクラスを利用して、年、月、日で分解させる
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = String(tmpCalendar.component(.year, from: date))
        let month = String(tmpCalendar.component(.month, from: date))
        let day = String(tmpCalendar.component(.day, from: date))

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString: String = formatter.string(from: date)

        self.dateString = dateString
        self.dateString2 = "\(year).\(month).\(day)"

        if self.recordArr.count != 0 {
            let predicate = NSPredicate(format: "date1 == %@", self.dateString)
            self.recordArrFilter = self.recordArr.filter(predicate).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)

            if self.recordArrFilter.isEmpty {
                self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"
            } else {
                self.label1.text = ""
            }
        }
        self.tableView.reloadData()
    }

    fileprivate let gregorian: Calendar = .init(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    //    祝日判定を行い結果を返すメソッド　trueなら祝日　falseなら普通の日
    func judgeHoliday(_ date: Date) -> Bool {
        //        祝日判定用のカレンダークラスのインスタンス　グレゴリ暦のカレンダーインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)

        //        祝日判定を行う日にちの年、月、日を取得(多分、とりあえず全ての年、月、日を取得してるとおもう）
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)

        //        祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()

        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recordArrFilter2 = self.recordArrFilter[indexPath.row]
        performSegue(withIdentifier: "ToEditRecordViewController", sender: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToEditRecordViewController" {
            self.recordArrFilter2 = self.recordArrFilter[sender as! Int]
            let editRecordViewController = segue.destination as! EditRecordViewController

            editRecordViewController.recordViewController = self
//            タップされた日付
            editRecordViewController.dateString = self.dateString

            editRecordViewController.label1_text = self.dateString2
            editRecordViewController.textField1_text = self.recordArrFilter2.folderName
            editRecordViewController.textField2_text = self.recordArrFilter2.number
            editRecordViewController.textField3_text = self.recordArrFilter2.times
            editRecordViewController.textField4_text = self.recordArrFilter2.nextReviewDate
            editRecordViewController.textView1_text = self.recordArrFilter2.memo
            editRecordViewController.dateString1 = self.recordArrFilter2.nextReviewDateForSorting

            editRecordViewController.recordArrFilter2 = self.recordArrFilter2
            editRecordViewController.tabBarController1 = self.tabBarController1
            if let studyViewController = studyViewController {
                editRecordViewController.studyViewContoller = studyViewController
            }

        } else if segue.identifier == "ToReviewViewController" {
            let reviewViewController = segue.destination as! ReviewViewController
            reviewViewController.tabBarController1 = self.tabBarController1
            if let studyViewController = studyViewController {
                reviewViewController.studyViewController = studyViewController
            }
        }
    }

    // date型 -> 年月日をIntで取得
    func getDay(_ date: Date) -> (Int, Int, Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year, month, day)
    }

    // 曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }

    // 土日や祝日の日の文字色を変える
    func calendar(_: FSCalendar, appearance _: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date) {
            return UIColor.red
        }

        // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 { // 日曜日
            return UIColor.red
        } else if weekday == 7 { // 土曜日
            return UIColor.blue
        }

        return nil
    }

    @IBAction func addButton(_: Any) {
        let addViewController = storyboard?.instantiateViewController(withIdentifier: "add") as! AddViewController
        addViewController.recordViewController = self
//       "yyyyMMdd"
        addViewController.dateString = self.dateString
//        "\(year).\(month).\(day)"
        addViewController.dateString2 = self.dateString2
        present(addViewController, animated: true, completion: nil)
    }

    //    日付にドットマークをつけるメソッド　dateの数だけ呼ばれる（要するに、表示されている月、30回呼ばれる）
    func calendar(_: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var resultsArr = [String]()
        if self.recordArr.count != 0 {
            for number in 0 ... self.recordArr.count - 1 {
                resultsArr.append(self.recordArr[number].date1)

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let date: String = formatter.string(from: date)

                if resultsArr.contains(date) {
                    resultsArr = []
                    let events = self.recordArr.filter("date1 == '\(date)'")
                    return events.count
                }
            }
        }
        return 0
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    //    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //            データベースから削除する
            try! self.realm.write {
                self.realm.delete(self.recordArrFilter[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
            self.fscalendar.reloadData()
        }
    }

    @IBAction func ToReveiwViewController(_: Any) {
        performSegue(withIdentifier: "ToReviewViewController", sender: nil)
    }

//    addViewController画面が閉じた時に呼ばれる
    func filteredRecordArr(recordArrFilter1: Results<Record>!) {
        let predicate = NSPredicate(format: "date1 == %@", dateString)
        self.recordArrFilter = recordArrFilter1.filter(predicate).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
    }
}
