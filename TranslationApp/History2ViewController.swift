
//  History2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.


import UIKit
import RealmSwift
import SVProgressHUD


class History2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var memoButton: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
//    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var acordionButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    
    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder>!
    
    var folderNameString: String = ""
    var expandSectionSet = Set<Int>()
    var sections = [String]()
    var tableDataList = [String]()
    var intArr = [Int]()
    var inputData3: String!
    var resultData3: String!
    
    var number = 0
    var numberForAcordion = 0
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("確認11 : \(self.folderNameString)")
        
        
        
        self.searchBar.backgroundImage = UIImage()
        //        xibファイルの登録
        let nib = UINib(nibName: "CustomHeaderFooterView", bundle: nil)
        //        再利用するための準備　ヘッダーの登録
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "Header")
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
        
//        何も入力されていなくてもreturnキー押せるようにする
        searchBar.enablesReturnKeyAutomatically  = false
        
        folderNameLabel.numberOfLines = 2
        
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
        
//        recordButton.layer.borderColor = borderColor
//        recordButton.layer.borderWidth = 3
//        recordButton.layer.cornerRadius = 10
        
        deleteAllButton.layer.borderColor = borderColor
        deleteAllButton.layer.borderWidth = 3
        deleteAllButton.layer.cornerRadius = 10
        
        backButton.layer.borderColor = borderColor
        backButton.layer.borderWidth = 3
        backButton.layer.cornerRadius = 10
        
       
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        self.searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        acordionButton.setTitle("表示", for: .normal)
       
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
       
        if self.searchBar.text != "" {
            self.search()
        }
    }
    
//    検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.search()
    }
    //        検索バーに入力があったら呼ばれる　（文字列検索機能）

    func search(){
        self.sections.removeAll()
        self.tableDataList.removeAll()

        if self.searchBar.text == "" {
            
            self.deleteAllButton.isEnabled = true
            //            空だったら、全て表示する。（通常表示）
            translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

            let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
            translationFolderArr = self.translationFolderArr.filter(predict)

            for number in 0...translationFolderArr[0].results.count - 1 {
                self.sections.append(translationFolderArr[0].results[number].inputData)
                self.tableDataList.append(translationFolderArr[0].results[number].resultData)
            }
        } else {
            
            self.deleteAllButton.isEnabled = false

            let results1 = translationFolderArr[0].results.filter("inputData CONTAINS '\(self.searchBar.text!)'")

            let results2 = translationFolderArr[0].results.filter("resultData CONTAINS '\(self.searchBar.text!)'")

            print(searchBar.text!)

            if results1.count != 0 {
                for results in 0...results1.count - 1 {
                    self.sections.append(results1[results].inputData)
                    self.tableDataList.append(results1[results].resultData)
                }
            }

            if results2.count != 0 {

                for results in 0...results2.count - 1 {
                    self.sections.append(results2[results].inputData)
                    self.tableDataList.append(results2[results].resultData)
                }
            }


        }
        self.tableView.reloadData()
    }
    
    
    
    
    //    開閉時の表示処理をする
    //    あとはセクションの開閉の表示処理をしてやるだけです。閉じてるセクションでは row の数を0にしてやればいい感じになる
    
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        print("確認45")
        if self.translationFolderArr[0].results.count == 0 {
            self.acordionButton.isEnabled = false
            self.deleteAllButton.isEnabled = false
        }
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
        
        if self.searchBar.text == "" {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        
        let image1 = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "hand.tap", withConfiguration: image1)

//        if indexPath.section == 0 && self.searchBar.text == "" {
//            cell.imageView?.image = image2
//        }
//
        if indexPath.section == 0 && self.searchBar.text == "" {
        cell.imageView?.image = image2
        }
        
        if indexPath.section != 0 && self.searchBar.text == "" {
            cell.imageView?.image = UIImage()
        }
        
        if self.searchBar.text != "" {
            cell.imageView?.image = UIImage()
        }
        
        cell.textLabel?.numberOfLines = 0
       
        return cell
    }
    
    //    UItableViewDelegateテーブルビューの指定されたセクションのヘッダに表示するビューをデリゲートに要求します。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("確認16 tableView始め")
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! CustomHeaderFooterView
        
        header.button2.isEnabled = true
        header.button2.isHidden = false
        
        header.button3.isHidden = false
        header.button3.isEnabled = true
        
        header.section = section
        print("確認41 : \(header.section)")
        header.inputDataLabel.text = String(section + 1) + ": " + sections[section]
       
    //        セクション保持
            header.delegate = self
      
//        headerの型はCustomHeaderFooterViewクラス型で、そのクラスには、delegateプロパティが宣言されている。そのdelegateプロぱにSingleAcordiontableViewHeaderFooterViewDelegate型（こいつはプロトコル）を指定している。このプロトコルには、一つのメソッドが定義されている。
        
        header.button2.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        header.button2.tag = section
        
        
        
        header.button3.addTarget(self, action: #selector(tapStarButton(_:)), for: .touchUpInside)
        header.button3.tag = section
        
        let result = translationFolderArr.first!.results[section].isChecked
        switch result {
        case 0:
            let image0 = UIImage(systemName: "star")
            header.button3.setImage(image0, for: .normal)
        case 1:
            let image1 = UIImage(systemName: "star.leadinghalf.filled")
            header.button3.setImage(image1, for: .normal)
        case 2:
            let image2 = UIImage(systemName: "star.fill")
            header.button3.setImage(image2, for: .normal)
        default:
            print("その他の値です")
        }
        
        if self.searchBar.text != "" {
            header.button2.isEnabled = false
            header.button2.isHidden = true
            
            header.button3.isEnabled = false
            header.button3.isHidden = true
        }
        print("確認16 tableView終わり")
    //        デリゲート設定
            return header
        //        headerはCVustomHeaderFooterViewクラスで、このクラスはUIViewクラスを継承したUITableViewHeaderFooterViewを継承しているからreturn headerできる。
    }
    
    
//    ブックマーク（星ボタン）をタップするごとに、Realm(TransaltionFolderクラス）のisCheckedプロパティに数字を書き込み保存 tableView,reloadData()でfunc viewForHeaderInSectionメソッド実行時に、星ボタンの状態を変える。
    @objc func tapStarButton(_ sender: UIButton){
        
        let translationArr = self.realm.objects(Translation.self)
        let result = translationArr[sender.tag].isChecked
        
        switch result {
        case 0:
            try! Realm().write{
                translationArr[sender.tag].isChecked = 1
                realm.add(translationArr, update: .modified)
            }
        case 1:
            try! Realm().write{
                translationArr[sender.tag].isChecked = 2
                realm.add(translationArr, update: .modified)
            }
        case 2:
            try! Realm().write{
                translationArr[sender.tag].isChecked = 0;               realm.add(translationArr, update: .modified)
            }
        default:
            print("値ありません。")
        }
        tableView.reloadData()
    }
    
    
//    右のドキュメントシステムアイコンをタップしたら、Realm（TranslationFolderファイル）のRecord2クラスに書き込み保存
    @objc func tapCellButton(_ sender: UIButton){
        
        if number == 0{
            let alert = UIAlertController(title: "保存しました", message: "ホーム画面の'単語・フレーズ'に保存されました" + " " + "以降この表示はでません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
            number = 1
        }
        
        print("確認40 \(sender.tag)")
        
        self.inputData3 = translationFolderArr[0].results[sender.tag].inputData
        self.resultData3 = translationFolderArr[0].results[sender.tag].resultData
        
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
        if self.searchBar.text == "" {
        return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
        //        .deleteだけでもよき
    }
    
//    セル削除メソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if self.searchBar.text == "" {
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
    }
    
//    セルをたっぷしたら、Edit1ViewControllerに画面遷移させて、そこで編集作業＋保存ボタンでRealmモデルクラス（TranslationFolderファイル）に保存
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.searchBar.text == "" {
            
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
    }
    
    @IBAction func memoButtonAction(_ sender: Any) {
        
        let memoViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
        
        if let sheet = memoViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        memoViewController.folderNameString = self.folderNameString
        
        present(memoViewController, animated: true, completion: nil)
    }
    
    
//    全削除ボタン
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
        
        if self.translationFolderArr[0].results.count != 0 {
            
            self.acordionButton.isEnabled = true
            
            if self.numberForAcordion == 0 {
                for number in 0...self.translationFolderArr[0].results.count - 1 {
                    self.expandSectionSet.insert(number)
                    print(expandSectionSet)
                    numberForAcordion = 1
                    self.acordionButton.setTitle("非表示", for: .normal)
                }
            } else {
                self.expandSectionSet.removeAll()
                self.acordionButton.setTitle("表示", for: .normal)
                tableView.reloadData()
                numberForAcordion = 0
            }
            tableView.reloadData()
        }
        
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


