
//  History2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.


import UIKit
import RealmSwift
import SVProgressHUD
import ContextMenuSwift
import Alamofire
import SideMenu
import AVFoundation


protocol SettingsDelegate {
    func tappedSettingsItem(indexPath: IndexPath)
}

class History2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SettingsDelegate{

    @IBOutlet weak var tableView: UITableView!
 
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var displayAllButton: UIButton!
    @IBOutlet weak var labelForDisplayAll: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backCellButton: UIButton!
    @IBOutlet weak var nextCellButton: UIButton!
    
    

    
    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder>!
    var translationArr: Results<Translation>!
    
    
    var folderNameString: String = ""
    var expandSectionSet = Set<Int>()
    var sections = [String]()
    var tableDataList = [String]()
    var intArr = [Int]()
    var inputData3: String!
    var resultData3: String!
    var tabBarController1: TabBarController!
    
    var number = 0
    var number1 = 0
    var numberForAcordion = 0
    var sender_tag: Int!
    
    var result: Int!
    var result1: Int!
    
    var menuNavigationController: SideMenuNavigationController!
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    var indexPath_row: Int!
    
   
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setImage(playButton, "play.circle.fill")
        setImage(nextCellButton, "arrowtriangle.right")
        setImage(backCellButton, "arrowtriangle.left")
        setImage(displayAllButton, "arrow.triangle.2.circlepath")
        setImage(repeatButton, "repeat")
       
    
        
//        let config = UIImage.SymbolConfiguration(pointSize: 27, weight: .medium, scale: .default)
//        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
//        nextCellButton.setImage(UIImage(systemName: "arrowtriangle.right", withConfiguration: config), for: .normal)
//        backCellButton.setImage(UIImage(systemName: "arrowtriangle.left", withConfiguration: config), for: .normal)
//
//        labelForDisplayAll.text = "表示"
//        displayAllButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config), for: .normal)
//        repeatButton.setImage(UIImage(systemName: "repeat", withConfiguration: config), for: .normal)
//        テキストの上に画像をつける
//        displayAllButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
//        displayAllButton.titleEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        
        self.searchBar.backgroundImage = UIImage()
        //        xibファイルの登録
        let nib = UINib(nibName: "CustomCellForHistory2ViewController", bundle: nil)
        //        再利用するための準備　ヘッダーの登録
        tableView.register(nib, forCellReuseIdentifier: "CustomCellForHistory2ViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .systemBlue
        
        searchBar.delegate = self
        
        tableView.allowsSelection = false
        // Do any additional setup after loading the view.
        
//        何も入力されていなくてもreturnキー押せるようにする
        searchBar.enablesReturnKeyAutomatically  = false
        
//        self.menuButton.setImage(UIImage(systemName: "text.justify"), for: .normal)
        
        let borderColor = UIColor.gray.cgColor
      
       

        
        
        
       
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton =  UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonTapped(sender: UIButton){
        self.searchBar.endEditing(true)
        
    }
        
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        repeatButton.tintColor = .systemGray2
        labelForDisplayAll.text = "表示"
        
        if self.indexPath_row == nil {
        nextCellButton.isEnabled = false
        backCellButton.isEnabled = false
        } else {
            nextCellButton.isEnabled = true
            backCellButton.isEnabled = true
        }
    
        
        self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController1.navigationController?.navigationBar.backgroundColor = UIColor.systemGray4
        
//        tabBarController1.navigationController?.navigationItem.title = self.folderNameString
       
        
        let navigationController = self.navigationController as! NavigationControllerForFolder
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.backgroundColor = .systemGray4
        navigationController.navigationBar.barTintColor = .systemGray4
        self.title = self.folderNameString
        
        let addBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(addBarButtonTapped(_:)) )
        
        self.navigationItem.rightBarButtonItems = [addBarButtonItem]
       
        
     
        
      
        
       
       
        
//        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
//        navigationController.navigationItem.rightBarButtonItem = rightButton
        
//        let labelFrame = CGRect(x: view.frame.size.width / 2, y: 0, width: 55.0, height: navigationController.navigationBar.frame.height)
//           let label = UILabel(frame: labelFrame)  // ラベルサイズと位置
//           label.textColor = UIColor.white // テキストカラー
//        navigationController.navigationBar.addSubview(label)
//        label.text = self.folderNameString
        
        
        print("フォルダー名　\(self.folderNameString)")
        
        
        tableView.layer.cornerRadius = 10
        
        print("確認10 : \(self.folderNameString)")
        
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        
        let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
        translationFolderArr = self.translationFolderArr.filter(predict)
        
        print("テスト1\(translationFolderArr)")
        
        self.sections = []
        self.tableDataList = []
        
        for number in 0...translationFolderArr[0].results.count - 1 {
            self.sections.append(translationFolderArr[0].results[number].inputData)
            self.tableDataList.append(translationFolderArr[0].results[number].resultData)
        }
        
        tableView.reloadData()
       
        if self.searchBar.text != "" {
            self.search()
        }
    }
    

    
    private func makeSettings() -> SideMenuSettings {
           var settings = SideMenuSettings()
           //動作を指定
        settings.presentationStyle = .menuSlideIn
        settings.menuWidth = 130

           //メニューの陰影度
//           settings.presentationStyle.onTopShadowOpacity = 10.0
           //ステータスバーの透明度
           settings.statusBarEndAlpha = 0
           return settings
          }
    
   


    @objc func addBarButtonTapped(_ sender: UIBarButtonItem){
        print("設定が押された")

        let menuViewController = storyboard?.instantiateViewController(withIdentifier: "Menu") as! SettingsViewController
        
        menuViewController.delegate = self
        //サイドメニューのナビゲーションコントローラを生成
        menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)
        
        menuNavigationController.leftSide = false
        //設定を追加
        menuNavigationController.settings = makeSettings()
        //左,右のメニューとして追加
        SideMenuManager.default.rightMenuNavigationController = menuNavigationController
        
        present(menuNavigationController, animated: true, completion: nil)
    }


    func tappedSettingsItem(indexPath: IndexPath){
        switch indexPath.row {
        case 0:
            let pharseViewController = storyboard?.instantiateViewController(withIdentifier: "Phrase")
            present(pharseViewController!, animated: true, completion: nil)
        case 1:
            let recordViewController = storyboard?.instantiateViewController(withIdentifier: "Record")
            present(recordViewController!, animated: true, completion: nil)
        case 2:
            let memoViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
            
            if let sheet = memoViewController.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            
            memoViewController.folderNameString = self.folderNameString
            
            present(memoViewController, animated: true, completion: nil)
        case 3:
            print("閉じる")
        default:
            print("nil")
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
        
        translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        
        let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
        translationFolderArr = self.translationFolderArr.filter(predict)
        
        if translationFolderArr.first!.results.count == 0 {
            return
        } else {
            
            self.sections.removeAll()
            self.tableDataList.removeAll()
            
            if self.searchBar.text == "" {
                
                displayAllButton.isEnabled = true
               
                
                //            空だったら、全て表示する。（通常表示）
                translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
                
                let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
                translationFolderArr = self.translationFolderArr.filter(predict)
                
                for number in 0...translationFolderArr[0].results.count - 1 {
                    self.sections.append(translationFolderArr[0].results[number].inputData)
                    self.tableDataList.append(translationFolderArr[0].results[number].resultData)
                }
                
            } else {
                
                displayAllButton.isEnabled = false
                
                
                let results1 = translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
                
                self.translationArr = translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
                
                
                print("サーチバーに入力された値がありました\(searchBar.text!)")
                
                if results1.count != 0 {
                    for results in 0...results1.count - 1 {
                        self.sections.append(results1[results].inputData)
                        self.tableDataList.append(results1[results].resultData)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    
    
    
    //    開閉時の表示処理をする
    //    あとはセクションの開閉の表示処理をしてやるだけです。閉じてるセクションでは row の数を0にしてやればいい感じになる
    
    
    //    func  numberOfSections(in tableView: UITableView) -> Int {
    //        print("確認45")
    //
    //        return self.sections.count > 0 ? sections.count : 0
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if translationFolderArr.first!.results.isEmpty {
            displayAllButton.isEnabled = false
        }
      
        return self.tableDataList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("確認47")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellForHistory2ViewCell", for: indexPath) as! CustomCellForHistory2ViewController
    
        cell.indexPath_row = indexPath.row
        cell.delegate = self
        cell.cell = cell
        
        cell.setData(self.sections[indexPath.row], indexPath.row)
        
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        
        if searchBar.text != "" {
            self.result = translationArr[indexPath.row].isChecked
        } else {
            self.result = translationFolderArr.first!.results[indexPath.row].isChecked
        }
        print("タグ確認1")
        print(result)
        switch result {
        case 0:
            let image0 = UIImage(systemName: "star")
            cell.checkMarkButton.setImage(image0, for: .normal)
        case 1:
            let image1 = UIImage(systemName: "star.leadinghalf.filled")
            cell.checkMarkButton.setImage(image1, for: .normal)
        case 2:
            let image2 = UIImage(systemName: "star.fill")
            cell.checkMarkButton.setImage(image2, for: .normal)
        default:
            print("その他の値です")
        }
        
       
            cell.displayButton1.tag = indexPath.row
            cell.displayButton1.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)
            
            cell.displayButton2.tag = indexPath.row
            cell.displayButton2.addTarget(self, action: #selector(tapDisplayButton(_:)), for: .touchUpInside)
            
        if searchBar.text != "" {
            self.result1 = translationArr[indexPath.row].isDisplayed
        } else {
            self.result1 = translationFolderArr.first!.results[indexPath.row].isDisplayed
        }
            print("タグ確認2")
            print(result1)
            
            switch result1 {
            case 0:
                cell.cellEditButton.setImage(UIImage(), for: .normal)
                cell.displayButton2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                cell.cellEditButton.isEnabled = false
                if indexPath.row == 0 {
                    cell.label2.text = ""
                    let image = UIImage(systemName: "hand.tap")
                    cell.displayButton2.setImage(image, for: .normal)
                } else if indexPath.row != 0 {
                    let image = UIImage()
                    cell.displayButton2.setImage(image, for: .normal)
                    cell.label2.text = " "
                }
            case 1:
                cell.cellEditButton.isEnabled = true
                cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                let image1 = UIImage()
                cell.displayButton2.setImage(image1, for: .normal)
                cell.setData2(self.tableDataList[indexPath.row])
                let image = UIImage(systemName: "ellipsis.circle")
                cell.cellEditButton.setImage(image, for: .normal)
            default:
                print("その他の値です")
            }
        
        cell.cellEditButton.tag = indexPath.row
        cell.cellEditButton.addTarget(self, action: #selector(tapCellEditButton(_:)), for: .touchUpInside)
    
        if translationFolderArr.first?.results[indexPath.row].resultData == "" {
            cell.label2.text = " "
        }
        
        if searchBar.text != "" && self.translationArr[indexPath.row].resultData == "" {
                cell.label2.text = " "
            }
       
        
        print(cell.label2.text!)
        
        return cell
    }
    
    
    
    @objc func tapCellButton(_ sender: UIButton){
        if self.searchBar.text != "" {
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
        } else {
            let translationArr1 = self.translationFolderArr.first!.results
            let result = translationArr1[sender.tag].isChecked
        
        switch result {
        case 0:
            try! Realm().write{
                translationArr1[sender.tag].isChecked = 1
                realm.add(translationArr1, update: .modified)
            }
        case 1:
            try! Realm().write{
                translationArr1[sender.tag].isChecked = 2
                realm.add(translationArr1, update: .modified)
            }
        case 2:
            try! Realm().write{
                translationArr1[sender.tag].isChecked = 0;               realm.add(translationArr1, update: .modified)
            }
        default:
            print("値ありません。")
        }
        }
       
        tableView.reloadData()
    }
    
    @objc func tapDisplayButton(_ sender: UIButton){
        if self.searchBar.text != "" {
        let result = translationArr[sender.tag].isDisplayed
        print("result確認\(result)")
        switch result {
        case 0:
            try! Realm().write{
                translationArr[sender.tag].isDisplayed = 1
                realm.add(translationArr, update: .modified)
            }
        case 1:
            try! Realm().write{
                translationArr[sender.tag].isDisplayed = 0
                realm.add(translationArr, update: .modified)
            }
       
        default:
            print("その他の値です")
        }
        } else {
    
            let translationArr1 = self.translationFolderArr.first!.results
        let result = translationArr1[sender.tag].isDisplayed
        print("result確認\(result)")
        switch result {
        case 0:
            try! Realm().write{
                translationArr1[sender.tag].isDisplayed = 1
                realm.add(translationArr1, update: .modified)
            }
        case 1:
            try! Realm().write{
                translationArr1[sender.tag].isDisplayed = 0
                realm.add(translationArr1, update: .modified)
            }
       
        default:
            print("その他の値です")
        }
    }
        
        tableView.reloadData()
    }
    
    @objc func tapCellEditButton(_ sender: UIButton){
        let edit = ContextMenuItemWithImage(title: "編集する", image: UIImage())
        let save = ContextMenuItemWithImage(title: "保存する", image: UIImage())
        let copy = ContextMenuItemWithImage(title: "コピーする", image: UIImage())
        let delete = ContextMenuItemWithImage(title: "削除する", image: UIImage())
       
        
        let cellForRow: IndexPath = IndexPath(row: sender.tag, section: 0)
        self.sender_tag = sender.tag
//        表示するアイテムを決定
        CM.items = [edit, save, copy, delete]
//        表示します
        CM.showMenu(viewTargeted: tableView.cellForRow(at: cellForRow)!, delegate: self, animated: true)
    }
    
    @IBAction func displayAllButton(_ sender: Any) {
       
        if searchBar.text != "" {
            let translationArr3 = self.translationArr!
            
            if self.labelForDisplayAll.text == "表示"{
                for number in 0...translationArr3.count - 1 {
                    try! Realm().write{
                        translationArr3[number].isDisplayed = 1
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "非表示"
                    }
                }
            } else {
                for number in 0...translationArr3.count - 1 {
                    try! Realm().write{
                        translationArr3[number].isDisplayed = 0
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "表示"
                    }
                }
            }
        } else {
            
            let translationArr3 = self.translationFolderArr.first!.results
            if self.labelForDisplayAll.text == "表示"{
                for number in 0...translationArr3.count - 1 {
                    try! Realm().write{
                        translationArr3[number].isDisplayed = 1
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "非表示"
                    }
                }
            } else {
                for number in 0...translationArr3.count - 1 {
                    try! Realm().write{
                        translationArr3[number].isDisplayed = 0
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "表示"
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    //    学習記録ボタンが押された時にRecordViewControllerへ値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToHistory2ViewController" {
            let recordViewController = segue.destination as! RecordViewController
            recordViewController.numberFromHistory2ViewController = 1
            print("func prepareが実行された")
        }
    }
    
    
    //    ボタンを押したら、次のcellへスクロール
    @IBAction func nextCellButton(_ sender: Any) {
        
        if speechSynthesizer.isPaused || speechSynthesizer.isPaused != true && speechSynthesizer.isSpeaking != true {
            if self.indexPath_row < self.sections.count - 1 {
                if repeatButton.tintColor != .systemBlue {
                self.speechSynthesizer.stopSpeaking(at: .immediate)
                }
                self.indexPath_row += 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView.reloadData()
            }
        } else {
            print("nextCellButton実行")
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            if self.indexPath_row < self.sections.count - 1 {
                self.indexPath_row += 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView.reloadData()
                self.speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
            }
        }
    }


//    ボタンを押したら、一つ前のcellへスクロール
    @IBAction func backCellButton(_ sender: Any) {
        if speechSynthesizer.isPaused || speechSynthesizer.isPaused != true && speechSynthesizer.isSpeaking != true {
            if self.indexPath_row > 0 {
                if repeatButton.tintColor != .systemBlue {
                self.speechSynthesizer.stopSpeaking(at: .immediate)
                }
                self.indexPath_row -= 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView.reloadData()
            }
        } else {
            
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            if self.indexPath_row > 0 {
                self.indexPath_row -= 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView.reloadData()
                self.speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
            }
        }
    }
    
//    音声一時停止/再生ボタン
    @IBAction func playButton(_ sender: Any) {
        if self.speechSynthesizer.isPaused {
            setImage(playButton, "pause.circle.fill")
                       self.speechSynthesizer.continueSpeaking()
            print("停止中")
        } else if speechSynthesizer.isSpeaking {
            setImage(playButton, "play.circle.fill")
                        self.speechSynthesizer.pauseSpeaking(at: .immediate)
                        print("おしゃべり中")
        } else if self.indexPath_row != nil {
            print("もう一度最初から再生")
            setImage(playButton, "pause.circle.fill")
            speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
        }
    }
    
    //    リピートボタン
    @IBAction func repeatButton(_ sender: Any) {
        if indexPath_row != nil {
            if repeatButton.tintColor == .systemGray2 {
                repeatButton.tintColor = .systemBlue
//                speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
            } else {
                repeatButton.tintColor = .systemGray2
            }
        }
        
    }
    
}
    
    




extension History2ViewController: ContextMenuDelegate {
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {
    }
    
    //    コンテキストメニューが表示された時の挙動を設定
    
    
    //    コンテキストメニューの選択肢が選択された時に実行される
    //            - Parameters:
    //                - contextMenu: そのコンテキストメニューだと思われる
    //                - cell: **選択されたコンテキストメニューの**セル
    //                - targetView: コンテキストメニューの発生源のビュー
    //                - item: 選択されたコンテキストのアイテム(タイトルとか画像とかが入ってる)
    //                - index: **選択されたコンテキストのアイテムの**座標
    //            - Returns: よくわからない(多分成功したらtrue...?
    //         */
    func contextMenuDidSelect(_ contextMenu: ContextMenu,
                              cell: ContextMenuCell,
                              targetedView: UIView,
                              didSelect item: ContextMenuItem,
                              forRowAt index: Int) -> Bool {
        
        print("コンテキストメニューの", index, "番目のセルが選択された！")
        print("そのセルには", item.title, "というテキストが書いてあるよ!")
        
        switch index {
        case 0:
            print("編集ボタン")
            
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit1") as! Edit1ViewController
            
            editViewController.textView1String = translationFolderArr[0].results[self.sender_tag].inputData
            editViewController.textView2String = translationFolderArr[0].results[sender_tag].resultData
            editViewController.translationIdNumber = translationFolderArr[0].results[sender_tag].id
            
            if self.searchBar.text != "" {
                editViewController.textView1String = translationArr[self.sender_tag].inputData
                editViewController.textView2String = translationArr[sender_tag].resultData
                editViewController.translationIdNumber = translationArr[sender_tag].id
            }
            
            //        if let sheet = editViewController?.sheetPresentationController {
            //            sheet.detents = [.medium()]
            //        }
            
            present(editViewController, animated: true, completion: nil)
            
        case 1:
            print("保存ボタン")
            savePhraseButton()
        case 2:
            print("コピーボタン")
            copyButton()
        case 3:
            deleteButton()
        default:
            print("他の値")
            
        }
        
        //サンプルではtrueを返していたのでとりあえずtrueを返してみる
        return true
        
    }
    
    /**
     コンテキストメニューが表示されたら呼ばれる
     */
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("コンテキストメニューが表示された!")
    }
    
    /**
     コンテキストメニューが消えたら呼ばれる
     */
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("コンテキストメニューが消えた!")
    }
    
    
    func copyButton(){
        let alert = UIAlertController(title: "コピーしました", message: "", preferredStyle: .alert)
        let alert1 = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
            if self.searchBar.text != "" {
                UIPasteboard.general.string = self.translationArr[self.sender_tag].inputAndResultData
            } else {
                UIPasteboard.general.string = self.translationFolderArr[0].results[self.sender_tag].inputAndResultData
            }
        })
        alert.addAction(alert1)
        present(alert, animated: true, completion: nil)
    }
    
    
    func deleteButton(){
        let alert = UIAlertController(title: "本当に削除しますか？", message: "保存した文章を\n左スワイプで削除することもできます", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
            try! self.realm.write {
                if self.searchBar.text != "" {
                    self.realm.delete(self.translationArr[self.sender_tag])
                    self.sections.remove(at: self.sender_tag)
                    self.tableDataList.remove(at: self.sender_tag)
                } else {
                    self.realm.delete(self.translationFolderArr[0].results[self.sender_tag])
                    self.sections.remove(at: self.sender_tag)
                    self.tableDataList.remove(at: self.sender_tag)
                }
                
            }
            self.tableView.reloadData()
        })
        
        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
        })
        
        alert.addAction(delete)
        alert.addAction(cencel)
        
        self.present(alert, animated: true, completion: nil)
    }
                                   
                                   
                                   
                                   
    //    右のドキュメントシステムアイコンをタップしたら、Realm（TranslationFolderファイル）のRecord2クラスに書き込み保存
    func savePhraseButton(){
        
            let alert = UIAlertController(title: "保存しました", message: "「単語・フレーズ」に保存されました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        if self.searchBar.text != "" {
            self.inputData3 = translationArr[self.sender_tag].inputData
            self.resultData3 = translationArr[self.sender_tag].resultData
        } else {
        self.inputData3 = translationFolderArr[0].results[self.sender_tag].inputData
        self.resultData3 = translationFolderArr[0].results[self.sender_tag].resultData
        }
        
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
    
//    セル削除メソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //            tableDataList.remove(at: indexPath.section * 2 + 1)
            //            sections.remove(at: indexPath.section * 2)
            
            try! realm.write {
                if self.searchBar.text != "" {
                    self.realm.delete(translationArr[indexPath.row])
                    sections.remove(at: indexPath.row)
                    tableDataList.remove(at: indexPath.row)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                    self.realm.delete(self.translationFolderArr[0].results[indexPath.row])
                    sections.remove(at: indexPath.row)
                    tableDataList.remove(at: indexPath.row)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
           
            tableView.reloadData()
        }
        
    }
}



extension History2ViewController: LongPressDetectionDelegate, AVSpeechSynthesizerDelegate{
    func longPressDetection(_ indexPath_row: Int, _ cell: UITableViewCell) {
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speeche(text: self.translationFolderArr[0].results[indexPath_row].resultData)
        self.indexPath_row = indexPath_row
        
        self.nextCellButton.isEnabled = true
        self.backCellButton.isEnabled = true
        
    }
    
    func speeche(text: String) {
        
        // 読み上げる、文字、言語などの設定
        let utterance = AVSpeechUtterance(string: text) // 読み上げる文字
        print("テキスト確認 \(text)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // 言語
//        utterance.rate = 0.5 // 読み上げ速度
//        utterance.pitchMultiplier = 1.0 // 読み上げる声のピッチ
//        utterance.preUtteranceDelay = 0.2 // 読み上げるまでのため
        self.speechSynthesizer.delegate = self
        self.speechSynthesizer.speak(utterance)
        
      }
    
     
    func setImage(_ button: UIButton, _ string: String){
        let config = UIImage.SymbolConfiguration(pointSize: 27, weight: .medium, scale: .default)
        button.setImage(UIImage(systemName: string, withConfiguration: config), for: .normal)
    }
    
    
//    読み上げ開始
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("読み上げ開始")
        setImage(playButton, "pause.circle.fill")
           
        }
    
    // 読み上げ終了
       internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
           print("読み上げ終了")
           
           
           if repeatButton.tintColor == .systemBlue {
               speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
           } else {
               setImage(playButton, "play.circle.fill")
           }
                
       }
    
//    読み上げ一時停止した時
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        
    }

    
}
    
//    セルをたっぷしたら、Edit1ViewControllerに画面遷移させて、そこで編集作業＋保存ボタンでRealmモデルクラス（TranslationFolderファイル）に保存
    



//    全削除ボタン
//  @IBAction func deleteAllButtonAction(_ sender: Any) {
//
//        let alert = UIAlertController(title: "削除", message: "本当に全て削除してもよろしいですか？", preferredStyle: .alert)
//        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in
//
//
//
//            self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
//
//            let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
//            self.translationFolderArr = self.translationFolderArr.filter(predict)
//
//
//            if self.searchBar.text != "" {
//                for number1 in 1...self.translationArr.count{
//                    var number2 = number1
//                    number2 = 0
//                    self.intArr.append(number2)
//                }
//                do {
//                    let realm = try Realm()
//                    try realm.write{
//                        for number3 in self.intArr{
//                            realm.delete(self.translationArr[number3])
//                        }
//                    }
//                } catch {
//                    print("エラー")
//                }
//            } else {
//            for number1 in 1...self.translationFolderArr[0].results.count{
//                var number2 = number1
//                number2 = 0
//                self.intArr.append(number2)
//            }
//
//            do {
//                let realm = try Realm()
//                try realm.write{
//                    for number3 in self.intArr{
//                        realm.delete(self.translationFolderArr[0].results[number3])
//                    }
//                }
//            } catch {
//                print("エラー")
//            }
//            }
//            self.intArr = []
//            self.sections = []
//            self.tableDataList = []
//
//            self.deleteAllButton.isEnabled = false
//
//            self.tableView.reloadData()
//            print("リロードされた")
//
//        })
//        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
//        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
//        })
//
//        alert.addAction(delete)
//        alert.addAction(cencel)
//
//
//        self.present(alert, animated: true, completion: nil)
//
//    }
//
//
//}
    
    //    ボタンタップでアコーディオン全表示、非表示切り替え
//    @IBAction func changeAcordionButton(_ sender: Any) {
//
//        if self.translationFolderArr[0].results.count != 0 {
//
//            self.acordionButton.isEnabled = true
//
//            if self.numberForAcordion == 0 {
//                for number in 0...self.translationFolderArr[0].results.count - 1 {
//                    self.expandSectionSet.insert(number)
//                    print(expandSectionSet)
//                    numberForAcordion = 1
//                    self.acordionButton.setTitle("非表示", for: .normal)
//                }
//            } else {
//                self.expandSectionSet.removeAll()
//                self.acordionButton.setTitle("表示", for: .normal)
//
//                numberForAcordion = 0
//            }
//            tableView.reloadData()
//        }
//
//    }
//
//}




