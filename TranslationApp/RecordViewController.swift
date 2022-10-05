//
//  RecordViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15.
//

import UIKit
import RealmSwift
import FSCalendar
import CalculateCalendarLogic
import Alamofire

class RecordViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
   
    
    @IBOutlet weak var fscalendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var reviewButton: UIButton!
    
    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
//    let record1Arr = try! Realm().objects(Record1.self)
    var recordArrFilter0: Results<Record>!
//    var recordArrFilter00: Results<Record1>!
    var recordArrFilter: Results<Record>!
    var recordArrFilter2: Record!
//    var record1ArrFilter: Results<Record1>!
//    var record1ArrFilter2: Record1!
   
    
    var dateString: String = ""
    var dateString2: String = ""
    var selectedDate: Date!
    var number = 0
    var tabBarController1: TabBarController!
    var numberFromHistory2ViewController: Int = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.isEnabled = false
        label1.text = "日付タップ → 「＋」で記録しよう！"
        
        reviewButton.isEnabled = false
        reviewButton.isHidden = true
        
        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        tableView.layer.borderWidth = 2.5
        
        self.fscalendar.delegate = self
        self.fscalendar.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.separatorColor = .gray
        
        let nib = UINib(nibName: "CustomCell2", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomCell2")

        // Do any additional setup after loading the view.
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.tabBarController1 != nil && self.numberFromHistory2ViewController != 1 {
                 self.tabBarController1.setBarButtonItem3()
        } else {
            self.numberFromHistory2ViewController = 0
        }
        if self.number == 1 {
        let predicate = NSPredicate(format: "date3 == %@", self.dateString)
        self.recordArrFilter = self.recordArrFilter0.filter(predicate).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
            
//            let predicate1 = NSPredicate(format: "date3_5 == %@", self.dateString)
//            self.record1ArrFilter = self.recordArrFilter00.filter(predicate1).sorted(byKeyPath: "date4_5", ascending: true)
//
//            print("両方確認\(recordArrFilter)")
//            print(record1ArrFilter)
            
            
        self.tableView.reloadData()
            self.number = 0
            print("ViewWillAppearが実行された。")
        }
    
        tableView.reloadData()
        
        reviewButton.isHidden = false
        reviewButton.isEnabled = true
        
        self.fscalendar.reloadData()
        
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.recordArrFilter != nil {
            return self.recordArrFilter.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell2", for: indexPath) as! CustomCell2
//        cell.delegate = self

        if self.recordArrFilter != nil {
        cell.setData(self.recordArrFilter[indexPath.row])
        }
        return cell
    }
    
//    選択された日付を取得する　日付がタップされた時の処理
//    選択された日付はdate変数に格納される
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        self.addButton.isEnabled = true
        self.label1.isHidden = true
        
        reviewButton.setTitle("復習日・内容を確認する", for: .normal)
        reviewButton.isHidden = false
        reviewButton.isEnabled = true
        
//        このdate変数をCalendarクラスを利用して、年、月、日で分解させる
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = String(tmpCalendar.component(.year, from: date))
        let month = String(tmpCalendar.component(.month, from: date))
        let day = String(tmpCalendar.component(.day, from: date))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString: String = formatter.string(from: date)
        
        
        self.dateString = dateString
        self.dateString2 = "\(year)年\(month)月\(day)日"
        
//        選択（タップ）された日付を格納する
        self.selectedDate = date
        
//        if self.record1Arr.count != 0 {
//        let predicate0 = NSPredicate(format: "date3_5 == %@", self.dateString)
//            self.record1ArrFilter = self.record1Arr.filter(predicate0).sorted(byKeyPath: "date4_5", ascending: true)
//            print("確認確認")
//            print(record1ArrFilter)
//        }
        
        
        if self.recordArr.count != 0 {
        let predicate = NSPredicate(format: "date3 == %@", self.dateString)
        self.recordArrFilter = self.recordArr.filter(predicate).sorted(byKeyPath: "date4", ascending: true)
            print(recordArrFilter)
            if recordArrFilter != nil {
            self.tableView.reloadData()
            }
        }
        
        
//        if self.recordArr.count != 0{
//        let predicate = NSPredicate(format: "date3 == %@", self.dateString)
//            self.recordArrFilter = self.recordArr.filter(predicate).sorted(byKeyPath: "date4", ascending: true)
//            self.tableView.reloadData()
//        }
    }
    
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recordArrFilter2 = self.recordArrFilter[indexPath.row]
        
        let editViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditViewController
    
        editViewContoller.recordViewController = self
        editViewContoller.dateString = self.dateString
        
        editViewContoller.label1_text = self.dateString2
        editViewContoller.textField1_text = recordArrFilter2.folderName
        editViewContoller.textField2_text = recordArrFilter2.number
        editViewContoller.textField3_text = recordArrFilter2.times
        editViewContoller.textField4_text = recordArrFilter2.nextReviewDate
        editViewContoller.textView1_text = recordArrFilter2.memo
        editViewContoller.dateString1 = recordArrFilter2.nextReviewDateForSorting
        
        editViewContoller.recordArrFilter2 = self.recordArrFilter2
        
        print("確認だよー")
        
//        let predicate = NSPredicate(format: "id == %@", recordArrFilter2.id)
//        let recordArrFilter2_id = Int(recordArrFilter2.id)
//        print(recordArrFilter2_id)
//        record1ArrFilter = self.record1ArrFilter.filter("id == \(recordArrFilter2_id)")
//        print("確認だよー２")
//        print(record1ArrFilter)
//
//        if record1ArrFilter.isEmpty != true {
//            editViewContoller.record1ArrFilter2 = record1ArrFilter.first
//            print(record1ArrFilter.first)
//        } else {
//            print("空でした。")
//        }
//
//        if let record1ArrFilter2 = self.record1ArrFilter?[indexPath.row] {
//            print(record1ArrFilter2)
//            editViewContoller.record1ArrFilter2 = record1ArrFilter2
//        } else {
//            print("nilでした")
//        }
//
//        self.record1ArrFilter[indexPath.row] != nil {
//            self.record1ArrFilter2 = self.record1ArrFilter[indexPath.row]
//        editViewContoller.record1ArrFilter2 = record1ArrFilter2
//        }
        
        
        present(editViewContoller, animated: true, completion: nil)
    }
    
    // date型 -> 年月日をIntで取得
        func getDay(_ date:Date) -> (Int,Int,Int){
            let tmpCalendar = Calendar(identifier: .gregorian)
            let year = tmpCalendar.component(.year, from: date)
            let month = tmpCalendar.component(.month, from: date)
            let day = tmpCalendar.component(.day, from: date)
            return (year,month,day)
        }

        //曜日判定(日曜日:1 〜 土曜日:7)
        func getWeekIdx(_ date: Date) -> Int{
            let tmpCalendar = Calendar(identifier: .gregorian)
            return tmpCalendar.component(.weekday, from: date)
        }

        // 土日や祝日の日の文字色を変える
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            //祝日判定をする（祝日は赤色で表示する）
            if self.judgeHoliday(date){
                return UIColor.red
            }

            //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
            let weekday = self.getWeekIdx(date)
            if weekday == 1 {   //日曜日
                return UIColor.red
            }
            else if weekday == 7 {  //土曜日
                return UIColor.blue
            }

            return nil
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func addButton(_ sender: Any) {
        let addViewController = self.storyboard?.instantiateViewController(withIdentifier: "add") as! AddViewController
        
        addViewController.recordViewController = self
        addViewController.dateString = self.dateString
        addViewController.dateString2 = self.dateString2
        addViewController.selectedDate = self.selectedDate
        
        self.present(addViewController, animated: true, completion: nil)
    }
    
//    日付にドットマークをつけるメソッド　dateの数だけ呼ばれる（要するに、表示されている月、30回呼ばれる）
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        var resultsArr = [String]()
        if self.recordArr.count != 0 {
            for number in 0...recordArr.count - 1 {
                resultsArr.append(recordArr[number].date3)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let date: String = formatter.string(from: date)
               
                if resultsArr.contains(date){
                    resultsArr = []
                    let events = self.recordArr.filter("date3 == '\(date)'")
                    return events.count
                }
            }
        }
        return 0

    }
    
   
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! realm.write  {
                self.realm.delete(self.recordArrFilter[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.reloadData()
            fscalendar.reloadData()
        }
    }
    
    @IBAction func ToReveiwViewController(_ sender: Any) {
        let reviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as! ReviewViewController
        
        
        present(reviewViewController, animated: true, completion: nil)
    }
    
}

//extension RecordViewController: ToEditViewContollerDelegate{
//    func ToEditViewContoller() {
//        let editViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditViewController
//
//        editViewContoller.dateString = self.dateString
//
//        self.present(editViewContoller, animated: true, completion: nil)
//    }
//
//}
