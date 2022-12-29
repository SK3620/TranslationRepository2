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

    @IBOutlet private var label1: UILabel!

    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var reviewButton: UIButton!

    private let realm = try! Realm()
    private let recordArr = try! Realm().objects(Record.self)

    private var recordArrFilter: Results<Record>!
    private var recordArrFilter2: Record!

    //　　　"yyyyMMdd"　It stores tapped string type date
    var dateString: String = ""
    //    "\(year).\(month).\(day)" It stores tapped string type date
    var dateString2: String = ""

    var tabBarController1: TabBarController!

    var studyViewController: StudyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForNavigationBar()

        self.settingsForTableViewAndFscalendar()

        self.addButton.isEnabled = false

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
    }

    private func settingsForTableViewAndFscalendar() {
        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        self.tableView.layer.borderWidth = 2.5
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .gray

        let nib = UINib(nibName: "CustomCellForRecord", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

        self.fscalendar.delegate = self
        self.fscalendar.dataSource = self
    }

    private func settingsForNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearence
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
//        self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"

        navigationController?.setNavigationBarHidden(true, animated: false)

        if self.tabBarController1 != nil, studyViewController == nil {
            self.settingsForNavigationControllerAndBar()
        }

        // performed when the screen transition from StudyViewController was performed
        if let studyViewController = studyViewController {
            studyViewController.hideNavigationControllerOfTabBarController()
            self.setItemsOnNaviationBar()
        }
        self.tableView.reloadData()
        self.fscalendar.reloadData()
    }

    private func settingsForNavigationControllerAndBar() {
        self.tabBarController1.setStringToNavigationItemTitle3()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        let createFolderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(self.tappedCreateFolderBarButtonItem(_:)))
        self.tabBarController1.navigationItem.rightBarButtonItems = [createFolderBarButtonItem]
    }

    @objc func tappedCreateFolderBarButtonItem(_: UIBarButtonItem) {
        self.tabBarController1.createFolder()
    }

    func setItemsOnNaviationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearence
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "学習記録"
        let leftBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.tappedBackBarButtonItem(_:)))
        self.navigationItem.leftBarButtonItems = [leftBarButtonItem]
    }

    @objc func tappedBackBarButtonItem(_: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        // performed when returning to the previous viewController (StudyViewController)
        if let studyViewController = studyViewController {
            studyViewController.hideNavigationControllerOfTabBarController()
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    // date type ->  get Int type year, month, day
    func getDay(_ date: Date) -> (Int, Int, Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year, month, day)
    }

    // Day of the week (Sunday:1 - Saturday:7)
    private func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }

    // Change text color on Saturdays, Sundays, and holidays.
    func calendar(_: FSCalendar, appearance _: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // Determine if it is a holiday or not (Holidays are displayed in red)
        if self.judgeHoliday(date) {
            return UIColor.red
        }
        // Determine Saturdays and Sundays (Saturdays are indicated in blue and Sundays in red).
        let weekday = self.getWeekIdx(date)
        if weekday == 1 { // sundays
            return UIColor.red
        } else if weekday == 7 { // saturdays
            return UIColor.blue
        }
        return nil
    }

    fileprivate let gregorian: Calendar = .init(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // method to determine if it is a holiday and return the result If true, it is a holiday If false, it is a normal day
    private func judgeHoliday(_ date: Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        // Get the year, month, and day of the date for which the holiday is to be determined (probably all years, months, and days for now)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // Create an instance of the holiday determination
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }

    // Get the selected date Process when the date is tapped
    // The selected date is stored in the date variable
    func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        self.addButton.isEnabled = true

        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = String(tmpCalendar.component(.year, from: date))
        let month = String(tmpCalendar.component(.month, from: date))
        let day = String(tmpCalendar.component(.day, from: date))

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString: String = formatter.string(from: date)
        self.dateString = dateString
        self.dateString2 = "\(year).\(month).\(day)"

        // when the add button in AddViewController is tapped, the tapped date is written to Record class (realm database) (it's written to property 'date1')
        // in the processs here, get the data from Record class(realm database) whose property 'date1' is equal to the tapped date
        if self.recordArr.count != 0 {
            let predicate = NSPredicate(format: "date1 == %@", self.dateString)
            self.recordArrFilter = self.recordArr.filter(predicate).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)

            // if there are no data in the tapped date
            if self.recordArrFilter.isEmpty {
                self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"
            } else {
                self.label1.text = ""
            }
        }
        self.tableView.reloadData()
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"
        if self.recordArrFilter != nil {
            return self.recordArrFilter.count
        } else {
            self.label1.text = "今日の日付をタップして\n学習した内容を画面右下の「＋」で記録しよう！"
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForRecord

        self.label1.text = ""

        if self.recordArrFilter != nil {
            cell.setData(self.recordArrFilter[indexPath.row])

            // determine if the contents of study in the tapped cell has already been reviewed or not
            self.determineIfTheReviewIsCompleted(cell: cell, indexPath: indexPath)
        }
        // tap when you've reviewed the content of study in the tapped date
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tappedCheckMarkButton2(_:)), for: .touchUpInside)

        return cell
    }

    private func determineIfTheReviewIsCompleted(cell: CustomCellForRecord, indexPath: IndexPath) {
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

    @objc func tappedCheckMarkButton2(_ sender: UIButton) {
        let result = self.recordArrFilter[sender.tag].isChecked
        switch result {
        case false:
            try! self.realm.write {
                recordArrFilter[sender.tag].isChecked = true
                realm.add(recordArrFilter, update: .modified)
                SVProgressHUD.showSuccess(withStatus: "復習が完了しました")
                SVProgressHUD.dismiss(withDelay: 1.5)
            }
        case true:
            try! self.realm.write {
                recordArrFilter[sender.tag].isChecked = false
                realm.add(recordArrFilter, update: .modified)
            }
            self.tableView.reloadData()
        }
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
            //            the tapped date
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
        }

        if segue.identifier == "ToReviewViewController" {
            let reviewViewController = segue.destination as! ReviewViewController
            reviewViewController.tabBarController1 = self.tabBarController1
            if let studyViewController = studyViewController {
                reviewViewController.studyViewController = studyViewController
            }
        }
    }

    // the screen transition to AddViewController
    @IBAction func addButton(_: Any) {
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForAddVC") as! UINavigationController
        let addViewController = navigationController.viewControllers[0] as! AddViewController
        addViewController.recordViewController = self
        //       "yyyyMMdd"
        addViewController.dateString = self.dateString
        //        "\(year).\(month).\(day)"
        addViewController.dateString2 = self.dateString2
        if self.studyViewController != nil {
            navigationController.modalPresentationStyle = .automatic
        } else {
            navigationController.modalPresentationStyle = .fullScreen
        }
        present(navigationController, animated: true, completion: nil)
    }

    // method to add a dot mark to the date Called as many times as the number of date
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

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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

    // called when the addViewController screen is closed
    func filteredRecordArr(recordArrFilter1: Results<Record>!) {
        let predicate = NSPredicate(format: "date1 == %@", dateString)
        self.recordArrFilter = recordArrFilter1.filter(predicate).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
    }
}
