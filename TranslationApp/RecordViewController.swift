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
    
    
    let realm = try! Realm()
    let recordArr = try! Realm().objects(Record.self)
    var recordArrFilter0: Results<Record>!
    var recordArrFilter: Results<Record>!
    var recordArrFilter2: Record!
   
    
    var dateString: String = ""
    var dateString2: String = ""
    var number = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.isEnabled = false
        label1.text = "日付タップ → 「＋」で記録しよう！"
        
        
        self.tableView.layer.borderColor = UIColor.systemGray4.cgColor
        tableView.layer.borderWidth = 2.5
        
        self.fscalendar.delegate = self
        self.fscalendar.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomCell2", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CustomCell2")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.number == 1 {
        let predicate = NSPredicate(format: "date3 == %@", self.dateString)
        self.recordArrFilter = self.recordArrFilter0.filter(predicate).sorted(byKeyPath: "date4", ascending: true)
        
        self.tableView.reloadData()
            self.number = 0
            print("ViewWillAppearが実行された。")
        }
        print("ViewWillAppearが呼ばれませんでした。")
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
        
        
        if self.recordArr.count != 0 {
        let predicate = NSPredicate(format: "date3 == %@", self.dateString)
        self.recordArrFilter = self.recordArr.filter(predicate).sorted(byKeyPath: "date4", ascending: true)
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
        
        editViewContoller.recordArrFilter2 = self.recordArrFilter2
        
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
        
        self.present(addViewController, animated: true, completion: nil)
    }
    
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
                    return 1
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
        }
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
