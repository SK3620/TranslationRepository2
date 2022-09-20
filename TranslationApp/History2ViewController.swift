
//  History2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.


import UIKit
import RealmSwift
import SVProgressHUD

class History2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var memoButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var acordionButton: UIButton!
    
    

    
    
    
    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder>!
    
    var folderNameString: String = ""
    var expandSectionSet = Set<Int>()
    var sections = [String]()
    var tableDataList = [String]()
    var intArr = [Int]()
    
    var number = 0
    var numberForAcordion = 0
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("確認11 : \(self.folderNameString)")
        
        
        //        xibファイルの登録
        let nib = UINib(nibName: "CustomHeaderFooterView", bundle: nil)
        //        再利用するための準備　ヘッダーの登録
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "Header")
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        let borderColor = UIColor.gray.cgColor
        memoButton.layer.borderColor = borderColor
        memoButton.layer.borderWidth = 3
        memoButton.layer.cornerRadius = 10
        
        acordionButton.layer.borderColor = borderColor
        acordionButton.layer.borderWidth = 3
        acordionButton.layer.cornerRadius = 10

        saveButton.layer.borderColor = borderColor
        saveButton.layer.borderWidth = 3
        saveButton.layer.cornerRadius = 10
        
        recordButton.layer.borderColor = borderColor
        recordButton.layer.borderWidth = 3
        recordButton.layer.cornerRadius = 10
        
        deleteAllButton.layer.borderColor = borderColor
        deleteAllButton.layer.borderWidth = 3
        deleteAllButton.layer.cornerRadius = 10
        
        backButton.layer.borderColor = borderColor
        backButton.layer.borderWidth = 3
        backButton.layer.cornerRadius = 10
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        acordionButton.setTitle("全表示", for: .normal)
        
        print("お呼ばれしました。")
        
        self.folderNameLabel.text = self.folderNameString
        
        tableView.layer.cornerRadius = 10
        
        print("確認10 : \(self.folderNameString)")
        
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        
        let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
        translationFolderArr = self.translationFolderArr.filter(predict)
        
        self.sections = []
        self.tableDataList = []
        
        for number in 0...translationFolderArr[0].results.count - 1 {
            self.sections.append(translationFolderArr[0].results[number].inputData)
            self.tableDataList.append(translationFolderArr[0].results[number].resultData)
        }
        
        tableView.reloadData()
        
        for i in sections{
            print("配列 \(i)")
        }
        
        for a in tableDataList{
            print("配列2 \(a)")
        }
        
        if translationFolderArr[0].results.count != 0 {
            self.deleteAllButton.isEnabled = true
        }
       
    }
    

    
    
    
    
    //    開閉時の表示処理をする
    //    あとはセクションの開閉の表示処理をしてやるだけです。閉じてるセクションでは row の数を0にしてやればいい感じになる
    
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        print("確認45")
        return self.sections.count > 0 ? sections.count : 0
    
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("確認46")
        if sections.count != 0 {
        return expandSectionSet.contains(section) ? 1 : 0
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("確認47")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableDataList[indexPath.section]
        
        let image1 = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "hand.tap", withConfiguration: image1)
        cell.imageView?.image = image2

        cell.textLabel?.numberOfLines = 0
       
        return cell
    }
    
    //    UItableViewDelegateテーブルビューの指定されたセクションのヘッダに表示するビューをデリゲートに要求します。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("確認16 tableView始め")
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! CustomHeaderFooterView
            header.section = section
        print("確認41 : \(header.section)")
        header.inputDataLabel.text = String(section + 1) + ": " + sections[section]
    //        セクション保持
            header.delegate = self
//        headerの型はCustomHeaderFooterViewクラス型で、そのクラスには、delegateプロパティが宣言されている。そのdelegateプロぱにSingleAcordiontableViewHeaderFooterViewDelegate型（こいつはプロトコル）を指定している。このプロトコルには、一つのメソッドが定義されている。
        
        header.button2.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        header.button2.tag = section
        
        print("確認16 tableView終わり")
    //        デリゲート設定
            return header
//        headerはCVustomHeaderFooterViewクラスで、このクラスはUIViewクラスを継承したUITableViewHeaderFooterViewを継承しているからreturn headerできる。
        }
    
    @objc func tapCellButton(_ sender: UIButton){
        
        if number == 0{
        let alert = UIAlertController(title: "保存しました", message: "ホーム画面の'単語・フレーズ'に保存されました" + " " + "以降この表示はでません", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
            
            number = 1
        }
        
        //        let image3 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        //        let image4 = UIImage(systemName: "doc.text", withConfiguration: image3)
        //        self.button2.setImage(image4, for: .normal)
        
        
        let inputData3 = translationFolderArr[0].results[sender.tag].inputData
        let resultData3 = translationFolderArr[0].results[sender.tag].resultData
        
        print("確認40 : \(sender.tag)")
        
        let record2 = Record2()
        let date5 = Date()
        
        record2.inputData3 = inputData3
        record2.resultData3 = resultData3
        record2.date5 = date5
        
        let allRecord2Arr = self.realm.objects(Record2.self)
        if allRecord2Arr.count != 0 {
            record2.id = allRecord2Arr.max(ofProperty: "id")! + 1
        }
    
        
        do {
            let realm = try Realm()
           try realm.write{
               realm.add(record2)
            }
        } catch {
            print("エラー")
        }
    }
    
   
    
    @IBAction func backButtton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
        
//        .deleteだけでもよき
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
//            tableDataList.remove(at: indexPath.section * 2 + 1)
//            sections.remove(at: indexPath.section * 2)
            
            try! realm.write {
                self.realm.delete(self.translationFolderArr[0].results[indexPath.section])
                sections.remove(at: indexPath.section)
                tableDataList.remove(at: indexPath.section)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit1") as! Edit1ViewController
        
        editViewController.textView1String = translationFolderArr[0].results[indexPath.section].inputData
        editViewController.textView2String = translationFolderArr[0].results[indexPath.section].resultData
        editViewController.translationIdNumber = translationFolderArr[0].results[indexPath.section].id

//        if let sheet = editViewController?.sheetPresentationController {
//            sheet.detents = [.medium()]
//        }
        
        present(editViewController, animated: true, completion: nil)
        
        
        
//        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment")
        //        if let sheet = commentViewController?.sheetPresentationController {
        //            sheet.detents = [.medium()]
        //        }
        //        present(commentViewController!, animated: true, completion: nil)
    }
    
    @IBAction func memoButtonAction(_ sender: Any) {
        
        let memoViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
        
        if let sheet = memoViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        memoViewController.folderNameString = self.folderNameString
        
        present(memoViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteAllButtonAction(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
          
            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
            
            let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
            self.translationFolderArr = self.translationFolderArr.filter(predict)
            
            
            for number1 in 1...self.translationFolderArr[0].results.count{
            var number2 = number1
            number2 = 0
            self.intArr.append(number2)
        }
            
            do {
                let realm = try Realm()
                try realm.write{
                    for number3 in self.intArr{
                        realm.delete(self.translationFolderArr[0].results[number3])
                    }
                }
            } catch {
                print("エラー")
            }
            self.intArr = []
            self.sections = []
            self.tableDataList = []
            
            self.deleteAllButton.isEnabled = false
            
            self.tableView.reloadData()
            print("リロードされた")
            
        })
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
        })
        
        alert.addAction(delete)
        alert.addAction(cencel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
//    ボタンタップでアコーディオン全表示、非表示切り替え
    
    @IBAction func changeAcordionButton(_ sender: Any) {
        
        if self.numberForAcordion == 0 {
            for number in 0...self.translationFolderArr[0].results.count - 1 {
                self.expandSectionSet.insert(number)
                print(expandSectionSet)
                numberForAcordion = 1
            }
        } else {
            self.expandSectionSet.removeAll()
            self.acordionButton.setTitle("非表示", for: .normal)
            tableView.reloadData()
            numberForAcordion = 0
        }
        tableView.reloadData()
    }
    
    
}


extension History2ViewController: SingleAccordionTableViewHeaderFooterViewDelegate{
    
//   開いているセクション情報を保持する。 テーブルを実装している ViewController でどこのセクションが開いていてどこが閉じているのかという情報を保持しないといけません。

//    こいつで開いているセクションを保持
//    セクションタップ時に呼ばれる
    func singleAccordionTableViewHeaderFooterView(_ header: CustomHeaderFooterView, section: Int) {
        if expandSectionSet.contains(section){
            expandSectionSet.remove(section)
            print(expandSectionSet)
        } else {
            expandSectionSet.insert(section)
            print("確認16 extensionはじめ")
            print(expandSectionSet)
        }
//        上記のようにカスタムセクションのデリゲートでセクションの開閉状態を保持します。
        //    セクションタップ時に指定のセクションのリロード処理を呼んであげます。
            tableView.reloadSections([section], with: .automatic)
        
        print("確認16 extension終わり")
    }
    
    
}


