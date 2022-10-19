//
//  ReviewViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/30.
//

import UIKit
import RealmSwift
import SVProgressHUD

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet var view1: UIView!
    
    
    
    
    var reviewDate = [String]()
    var folderName = [String]()
    var content = [String]()
    var memo = [String]()
    var times = [String]()
    var inputDate = [String]()
    
    var tabBarController1: UITabBarController!
    var history2ViewController: History2ViewController!

    
    let realm = try! Realm()
    var recordArr = try! Realm().objects(Record.self).sorted(byKeyPath: "nextReviewDateForSorting", ascending: true)
    var resultsArr: Results<Record>!
   
    
    var datePicker: UIDatePicker = UIDatePicker()
    
    var dateString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .gray
        
        let nib = UINib(nibName: "ReviewCustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ReviewCustomCell")

        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 6
        
       
        
        tableView.layer.borderColor = UIColor.systemGray4.cgColor
        tableView.layer.borderWidth = 2.5
        
        // ピッカー設定
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        // 決定バーの生成
        let toolbar4 = UIToolbar()
         toolbar4.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem4 = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done4))
        let cancelItem4 = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancel4))
        toolbar4.setItems([cancelItem4, spaceItem, doneItem4], animated: true)
        // インプットビュー設定
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar4
//        デフォルト設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        datePicker.date = formatter.date(from: dateString)!
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    @objc func done4(){
        textField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        let dateString = formatter.string(from: datePicker.date)
        textField.text = dateString
        
        let predict = NSPredicate(format: "nextReviewDate == %@", dateString)
         resultsArr = self.recordArr.filter(predict)
        
        reviewDate = []
        times = []
        folderName = []
        content = []
        memo = []
        inputDate = []
        
        if recordArr.isEmpty != true {
            if resultsArr.count != 0 {
                for number in 0...resultsArr.count - 1 {
                    self.reviewDate.append(resultsArr[number].nextReviewDate)
                    self.times.append(resultsArr[number].times)
                    self.folderName.append(resultsArr[number].folderName)
                    self.content.append(resultsArr[number].number)
                    self.memo.append(resultsArr[number].memo)
                    self.inputDate.append(recordArr[number].inputDate)

                    self.label1.text = "\(dateString)に復習する内容があります"
                }
            } else {
                for number in 0...recordArr.count - 1 {
                    self.reviewDate.append(recordArr[number].nextReviewDate)
                    self.times.append(recordArr[number].times)
                    self.folderName.append(recordArr[number].folderName)
                    self.content.append(recordArr[number].number)
                    self.memo.append(recordArr[number].memo)
                    self.inputDate.append(recordArr[number].inputDate)
                    
                    self.resultsArr = self.recordArr

                    self.label1.text = "\(dateString)に復習する内容はありません\n代わりに全データを日付順に表示しています"
                }
            }
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }

        tableView.reloadData()
        print("確認する！　\(resultsArr)")
    }
    
    @objc func cancel4(){
        textField.endEditing(true)
        textField.text = ""
        
        reviewDate = []
        folderName = []
        content = []
        memo = []
        times = []
        inputDate = []

        if recordArr.isEmpty != true {
            
            for number in 0...recordArr.count - 1 {
                self.reviewDate.append(recordArr[number].nextReviewDate)
                self.times.append(recordArr[number].times)
                self.folderName.append(recordArr[number].folderName)
                self.content.append(recordArr[number].number)
                self.memo.append(recordArr[number].memo)
                self.inputDate.append(recordArr[number].inputDate)
                print("実行された")

                self.resultsArr = self.recordArr
                self.label1.text = "全てのデータを日付順に表示しています"
            }
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let date = Date()
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy.M.d", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateString = dateFomatter.string(from: date)
        
        
        
        self.tabBarController1?.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "次回復習日・内容 \(dateString)"
        self.navigationController?.navigationBar.barTintColor = .systemGray4
        self.navigationController?.navigationBar.backgroundColor = .systemGray4
        
        let editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(editButton(_:)))
        
        self.navigationItem.rightBarButtonItems = [editBarButtonItem]
        
        
        print("Record確認\(self.recordArr)")
        
        if recordArr.isEmpty != true {
            for number in 0...recordArr.count - 1 {
                self.reviewDate.append(recordArr[number].nextReviewDate)
                self.times.append(recordArr[number].times)
                self.folderName.append(recordArr[number].folderName)
                self.content.append(recordArr[number].number)
                self.memo.append(recordArr[number].memo)
                self.inputDate.append(recordArr[number].inputDate)

                self.resultsArr = self.recordArr

                self.label1.text = "全てのデータを日付順に表示しています"
            }
        } else {
            self.folderName = []
            self.label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        
        if self.history2ViewController == nil {
            backButton.isHidden = true
            backButton.isEnabled = false
            editButton.isEnabled = false
            editButton.isHidden = true
            label3.text = ""
            editButton.setTitle("", for: .normal)
            view1.backgroundColor = .systemGray4
        } else {
        label3.text = "次回復習日・内容 \(dateString)"
            editButton.setTitle("編集", for: .normal)
            view1.backgroundColor = .white
            backButton.setTitle("戻る", for: .normal)
            backButton.isEnabled = true
            backButton.isHidden = false
        }

    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.label1.text == "全てのデータを日付順に表示しています" && self.textField.text == "" && folderName.isEmpty {
            label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
        }
        return self.folderName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCustomCell", for: indexPath) as! ReviewCustomCell
        cell.setData(reviewDate[indexPath.row], folderName[indexPath.row], content[indexPath.row], memo[indexPath.row], times[indexPath.row], inputDate[indexPath.row])
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(tapCheckMarkButton(_:)), for: .touchUpInside)
        
        let result = self.resultsArr[indexPath.row].isChecked
        switch result {
        case 0:
            let image = UIImage(systemName: "checkmark.circle")
            cell.checkMarkButton.setImage(image, for: .normal)
//            cell.checkMarkButton.setTitle("完了", for: .normal)
            cell.checkMarkButton.tintColor = UIColor.gray
            
        case 1:
            let image = UIImage(systemName: "checkmark.circle.fill")
//            cell.checkMarkButton.setTitle("復習完了", for: .normal)
            cell.checkMarkButton.setImage(image, for: .normal)
            cell.checkMarkButton.tintColor = UIColor.systemGreen
        default:
            print("他の値です")
        }
        
        return cell
    }
    
    @objc func tapCheckMarkButton(_ sender: UIButton){
        let result = self.resultsArr[sender.tag].isChecked
        print("レルム確認: \(resultsArr)")
        switch result{
        case 0:
            try! realm.write{
                resultsArr[sender.tag].isChecked = 1
                realm.add(resultsArr, update: .modified)
            }
            SVProgressHUD.show()
            SVProgressHUD.showSuccess(withStatus: "復習が完了しました")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { () -> Void in
                SVProgressHUD.dismiss()
            })
        case 1:
            try! realm.write{
                resultsArr[sender.tag].isChecked = 0
                realm.add(resultsArr, update: .modified)
            }
        default:
            print("他の値です")
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! realm.write  {
                print("確認だよ")
//                print(resultsArr1)
                
                self.realm.delete(self.resultsArr[indexPath.row])
                self.folderName.remove(at: indexPath.row)
                self.content.remove(at: indexPath.row)
                self.times.remove(at: indexPath.row)
                self.reviewDate.remove(at: indexPath.row)
                self.memo.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("実行確認")
            }
            
            if self.resultsArr.count == 0 && self.recordArr.count == 0 {
                label1.text = "登録されたデータがありません\n「戻る」→「＋」ボタンで復習記録を追加しよう！"
            } else if self.resultsArr.count == 0 {
                label1.text = "\(self.dateString)に登録されたデータはありません\n代わりに全てのデータを日付順に表示しています"
                self.resultsArr = self.recordArr
            }
            
           
            tableView.reloadData()
        }
    }
    
    
    @objc func editButton(_ sender: UIBarButtonItem){
    if tableView.isEditing {
        tableView.isEditing = false
        editButton.setTitle("編集", for: .normal)
        } else {
            tableView.isEditing = true
            editButton.setTitle("完了", for: .normal)
        }
        
    }
    
    
    @IBAction func editButton1(_ sender: Any) {
        if tableView.isEditing {
            tableView.isEditing = false
            editButton.setTitle("編集", for: .normal)
            } else {
                tableView.isEditing = true
                editButton.setTitle("完了", for: .normal)
            }
    }
    
    
    
//    @IBAction func returnButton(_ sender: Any) {
//        if self.textField.text != "" {
//            let formatter = DateFormatter()
//
//            let date = self.stringToDate(dateString: textField.text!, fromFormat: "yyyy.M.d")!
//            print("日付確認1\(date)")
//            let before = Calendar.current.date(byAdding: .day, value: -1, to: date)
//            print("日付確認2\(before)")
//
//            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMd", options: 0, locale: Locale(identifier: "ja_JP"))
//            let dateString5 = formatter.string(from: before!)
//            print("日付確認2.5 \(dateString5)")
//            let dateString6: Date = self.stringToDate(dateString: dateString5, fromFormat: "yyyy.M.d")!
//            formatter.dateFormat = "yyyy.M.d"
//            let dateString7 = formatter.string(from: dateString6)
//            print("日付確認3 \(dateString7)")
//            textField.text = dateString7
//        }
//    }
//
//
//    @IBAction func forwardButton(_ sender: Any) {
//        if self.textField.text != "" {
//            let formatter = DateFormatter()
//
//            let date = self.stringToDate(dateString: textField.text!, fromFormat: "yyyy.M.d")!
//            print("日付確認3.5: \(date)")
//            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMd", options: 0, locale: Locale(identifier: "ja_JP"))
//            let dateString8 = formatter.string(from: date)
//            let dateString9 = self.stringToDate(dateString: dateString8, fromFormat: "yyyy.M.d")
//            print(dateString9)
//
//            let after = Calendar.current.date(byAdding: .day, value: 1, to: dateString9!)!
//            print("日付確認4: \(after)")
//        }
//
//    }
//
//    func stringToDate(dateString: String, fromFormat: String) -> Date? {
//               let formatter = DateFormatter()
//               formatter.locale = .current
//               formatter.dateFormat = fromFormat
//               return formatter.date(from: dateString)
//           }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
    

 
