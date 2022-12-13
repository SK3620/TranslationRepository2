
//  History2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.

import Alamofire
import AVFoundation
import ContextMenuSwift
import RealmSwift
import SideMenu
import SVProgressHUD
import UIKit

protocol SettingsDelegate: AnyObject {
    func tappedSettingsItem(indexPath: IndexPath)
}

class StudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SettingsDelegate {
    @IBOutlet var tableView: UITableView!

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var displayAllButton: UIButton!
    @IBOutlet var labelForDisplayAll: UILabel!
    @IBOutlet var repeatButton: UIButton!
    @IBOutlet var label1: UILabel!

    @IBOutlet var playButton: UIButton!
    @IBOutlet var backCellButton: UIButton!
    @IBOutlet var nextCellButton: UIButton!
    @IBOutlet var speakSpeedButton: UIButton!
    @IBOutlet var speakVoice: UIButton!

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
    var number2 = 0
    var numberForAcordion = 0
    var sender_tag: Int!

    var result: Int!
    var isDisplayed: Bool!
    var menuNavigationController: SideMenuNavigationController!

    let speechSynthesizer = AVSpeechSynthesizer()
    var indexPath_row: Int!

    var speakSpeed: Float = 0.5
    var voice: String = "com.apple.ttsbundle.siri_Nicky_en-US_compact"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.setNavigationBar()
        // 利用可能な英語音声の確認
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.language == "en-US" {
                print(voice)
            }
        }

        setImage(self.playButton, "play.circle.fill")
        setImage(self.nextCellButton, "arrowtriangle.right")
        setImage(self.backCellButton, "arrowtriangle.left")
        setImage(self.displayAllButton, "arrow.triangle.2.circlepath")
        setImage(self.repeatButton, "repeat")

        self.speakSpeedButton.setTitle("1.0x", for: .normal)
        self.speakVoice.setTitle("女性", for: .normal)

        self.searchBar.backgroundImage = UIImage()
        //        xibファイルの登録
        let nib = UINib(nibName: "CustomCellForStudy", bundle: nil)
        //        再利用するための準備　ヘッダーの登録
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCellForStudy")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .systemBlue

        self.searchBar.delegate = self

        self.tableView.allowsSelection = false
        // Do any additional setup after loading the view.

        //        何も入力されていなくてもreturnキー押せるようにする
        self.searchBar.enablesReturnKeyAutomatically = false

        // キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonTapped(sender _: UIButton) {
        self.searchBar.endEditing(true)
    }

    func setNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearence
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        playBackground()

        self.repeatButton.tintColor = .systemGray2
        self.labelForDisplayAll.text = "表示"

        playBackground()

        self.repeatButton.tintColor = .systemGray2
        self.labelForDisplayAll.text = "表示"

        if self.indexPath_row == nil {
            self.label1.text = "文章を長押しで音声再生"
            self.label1.textColor = .orange
        }

        if self.indexPath_row == nil {
            self.nextCellButton.isEnabled = false
            self.backCellButton.isEnabled = false
        } else {
            self.nextCellButton.isEnabled = true
            self.backCellButton.isEnabled = true
        }

        self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController1.navigationController?.navigationBar.backgroundColor = UIColor.systemGray4

        let navigationController = self.navigationController as! NavigationControllerForFolder
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.backgroundColor = .systemGray4
        navigationController.navigationBar.barTintColor = .systemGray4
        title = self.folderNameString

        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(self.addBarButtonTapped(_:)))

        navigationItem.rightBarButtonItems = [settingsBarButtonItem]

        self.tableView.layer.cornerRadius = 10

        print("確認10 : \(self.folderNameString)")

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

        let predict = NSPredicate(format: "folderName == %@", folderNameString)
        self.translationFolderArr = self.translationFolderArr.filter(predict)

        self.sections = []
        self.tableDataList = []

        for number in 0 ... self.translationFolderArr[0].results.count - 1 {
            self.sections.append(self.translationFolderArr[0].results[number].inputData)
            self.tableDataList.append(self.translationFolderArr[0].results[number].resultData)
        }

        self.tableView.reloadData()

        if self.searchBar.text != "" {
            self.search()
        }
    }

    func SetTabBarController1() {
        self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func makeSettings() -> SideMenuSettings {
        var settings = SideMenuSettings()
        // 動作を指定
        settings.presentationStyle = .menuSlideIn
        settings.menuWidth = 170

        // ステータスバーの透明度
        settings.statusBarEndAlpha = 0
        return settings
    }

    @objc func addBarButtonTapped(_: UIBarButtonItem) {
        print("設定が押された")

        let menuViewController = storyboard?.instantiateViewController(withIdentifier: "Menu") as! SettingsForStudyViewController

        menuViewController.delegate = self
        // サイドメニューのナビゲーションコントローラを生成
        self.menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)

        self.menuNavigationController.leftSide = false
        // 設定を追加
        self.menuNavigationController.settings = self.makeSettings()
        // 左,右のメニューとして追加
        SideMenuManager.default.rightMenuNavigationController = self.menuNavigationController

        present(self.menuNavigationController, animated: true, completion: nil)
    }

    func tappedSettingsItem(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
//            let pharseWordViewController = storyboard?.instantiateViewController(withIdentifier: "PhraseWord")
//            present(pharseWordViewController!, animated: true, completion: nil)

            let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForPhraseWord") as! UINavigationController
            let pagingPharseWordViewController = navigationController.viewControllers[0] as! PagingPhraseWordViewController
            pagingPharseWordViewController.setItemsOnNavigationBar()
            pagingPharseWordViewController.studyViewController = self
            pagingPharseWordViewController.tabBarController1 = self.tabBarController1
            present(navigationController, animated: true, completion: nil)
        case 1:
            let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForRecordView") as! UINavigationController
            let recordViewController = navigationController.viewControllers[0] as! RecordViewController
            recordViewController.tabBarController1 = self.tabBarController1
            recordViewController.studyViewController = self
            recordViewController.setItemsOnNaviationBar()
            present(navigationController, animated: true, completion: nil)
        case 2:

            let memoForStudyViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoForStudyViewController

            if let sheet = memoForStudyViewController.sheetPresentationController {
                sheet.detents = [.medium()]
            }

            memoForStudyViewController.folderNameString = self.folderNameString

            present(memoForStudyViewController, animated: true, completion: nil)
        case 3:
            //            太文字再生
            self.repeatButton.tintColor = .systemGray2
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            setImage(self.playButton, "play.circle.fill")
        case 4:
            //            小文字再生
            self.repeatButton.tintColor = .systemGray2
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            setImage(self.playButton, "play.circle.fill")

            print("閉じる")
        default:
            print("nil")
        }
    }

    //    検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_: UISearchBar, textDidChange _: String) {
        self.search()
    }

    //        検索バーに入力があったら呼ばれる　（文字列検索機能）
    func search() {
        self.speechSynthesizer.pauseSpeaking(at: .immediate)
        self.playButton.isEnabled = false
        setImage(self.playButton, "play.circle.fill")
        self.backCellButton.isEnabled = false
        self.nextCellButton.isEnabled = false
        self.label1.text = "文章を長押しで音声再生"

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

        let predict = NSPredicate(format: "folderName == %@", folderNameString)
        self.translationFolderArr = self.translationFolderArr.filter(predict)

        if self.translationFolderArr.first!.results.count == 0 {
            return
        } else {
            self.sections.removeAll()
            self.tableDataList.removeAll()

            if self.searchBar.text == "" {
                self.displayAllButton.isEnabled = true

                //            空だったら、全て表示する。（通常表示）
                self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)

                let predict = NSPredicate(format: "folderName == %@", folderNameString)
                self.translationFolderArr = self.translationFolderArr.filter(predict)

                for number in 0 ... self.translationFolderArr[0].results.count - 1 {
                    self.sections.append(self.translationFolderArr[0].results[number].inputData)
                    self.tableDataList.append(self.translationFolderArr[0].results[number].resultData)
                }

            } else {
                self.displayAllButton.isEnabled = false

                let results1 = self.translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")

                self.translationArr = self.translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")

                if results1.count != 0 {
                    self.indexPath_row = 0
                    for results in 0 ... results1.count - 1 {
                        self.sections.append(results1[results].inputData)
                        self.tableDataList.append(results1[results].resultData)
                    }
                } else {
                    self.playButton.isEnabled = false
                    self.backCellButton.isEnabled = false
                    self.nextCellButton.isEnabled = false
                }
            }
            self.tableView.reloadData()
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.translationFolderArr.first!.results.isEmpty {
            self.displayAllButton.isEnabled = false
        }

        return self.tableDataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellForStudy", for: indexPath) as! CustomCellForStudy

        cell.indexPath_row = indexPath.row
        cell.delegate = self
        cell.cell = cell

        if indexPath.row == self.indexPath_row {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .white
        }

        cell.setData(self.sections[indexPath.row], indexPath.row)

        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tapCellButton(_:)), for: .touchUpInside)

        if self.searchBar.text != "" {
            self.result = self.translationArr[indexPath.row].isChecked
        } else {
            self.result = self.translationFolderArr.first!.results[indexPath.row].isChecked
        }

        switch self.result {
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
        cell.displayButton1.addTarget(self, action: #selector(self.tapDisplayButton(_:)), for: .touchUpInside)

        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(self.tapDisplayButton(_:)), for: .touchUpInside)

        if self.searchBar.text != "" {
            self.isDisplayed = self.translationArr[indexPath.row].isDisplayed
        } else {
            self.isDisplayed = self.translationFolderArr.first!.results[indexPath.row].isDisplayed
        }

        switch self.isDisplayed {
        case false:
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
        case true:
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
        cell.cellEditButton.addTarget(self, action: #selector(self.tapCellEditButton(_:)), for: .touchUpInside)

        if self.translationFolderArr.first?.results[indexPath.row].resultData == "" {
            cell.label2.text = " "
        }

        if self.searchBar.text != "", self.translationArr[indexPath.row].resultData == "" {
            cell.label2.text = " "
        }

        print(cell.label2.text!)

        return cell
    }

    @objc func tapCellButton(_ sender: UIButton) {
        if self.searchBar.text != "" {
            let result = self.translationArr[sender.tag].isChecked

            switch result {
            case 0:
                try! Realm().write {
                    translationArr[sender.tag].isChecked = 1
                    realm.add(translationArr, update: .modified)
                }
            case 1:
                try! Realm().write {
                    translationArr[sender.tag].isChecked = 2
                    realm.add(translationArr, update: .modified)
                }
            case 2:
                try! Realm().write {
                    translationArr[sender.tag].isChecked = 0; realm.add(translationArr, update: .modified)
                }
            default:
                print("値ありません。")
            }
        } else {
            let translationArr1 = self.translationFolderArr.first!.results
            let result = translationArr1[sender.tag].isChecked

            switch result {
            case 0:
                try! Realm().write {
                    translationArr1[sender.tag].isChecked = 1
                    realm.add(translationArr1, update: .modified)
                }
            case 1:
                try! Realm().write {
                    translationArr1[sender.tag].isChecked = 2
                    realm.add(translationArr1, update: .modified)
                }
            case 2:
                try! Realm().write {
                    translationArr1[sender.tag].isChecked = 0; realm.add(translationArr1, update: .modified)
                }
            default:
                print("値ありません。")
            }
        }

        self.tableView.reloadData()
    }

    @objc func tapDisplayButton(_ sender: UIButton) {
        if self.searchBar.text != "" {
            let result = self.translationArr[sender.tag].isDisplayed
            print("result確認\(result)")
            switch result {
            case false:
                try! Realm().write {
                    translationArr[sender.tag].isDisplayed = true
                    realm.add(translationArr, update: .modified)
                }
            case true:
                try! Realm().write {
                    translationArr[sender.tag].isDisplayed = false
                    realm.add(translationArr, update: .modified)
                }
            }
        } else {
            let translationArr1 = self.translationFolderArr.first!.results
            let result = translationArr1[sender.tag].isDisplayed

            switch result {
            case false:
                try! Realm().write {
                    translationArr1[sender.tag].isDisplayed = true
                    realm.add(translationArr1, update: .modified)
                }
            case true:
                try! Realm().write {
                    translationArr1[sender.tag].isDisplayed = false
                    realm.add(translationArr1, update: .modified)
                }
            }
        }

        self.tableView.reloadData()
    }

    @objc func tapCellEditButton(_ sender: UIButton) {
        let edit = ContextMenuItemWithImage(title: "編集する", image: UIImage(systemName: "square.and.pencil")!)
        let save = ContextMenuItemWithImage(title: "お気に入りにする", image: UIImage(systemName: "heart")!)
        let folder = ContextMenuItemWithImage(title: "保存先を変更する", image: UIImage(systemName: "folder")!)
        let copy = ContextMenuItemWithImage(title: "コピーする", image: UIImage(systemName: "doc.on.doc")!)
        let delete = ContextMenuItemWithImage(title: "削除する", image: UIImage(systemName: "trash")!)

        let cellForRow = IndexPath(row: sender.tag, section: 0)
        self.sender_tag = sender.tag
        //        表示するアイテムを決定
        CM.items = [edit, save, folder, copy, delete]
        //        表示します
        CM.showMenu(viewTargeted: self.tableView.cellForRow(at: cellForRow)!, delegate: self, animated: true)
    }

    @IBAction func displayAllButton(_: Any) {
        if self.searchBar.text != "" {
            let translationArr3 = self.translationArr!

            if self.labelForDisplayAll.text == "表示" {
                for number in 0 ... translationArr3.count - 1 {
                    try! Realm().write {
                        translationArr3[number].isDisplayed = true
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "非表示"
                    }
                }
            } else {
                for number in 0 ... translationArr3.count - 1 {
                    try! Realm().write {
                        translationArr3[number].isDisplayed = false
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "表示"
                    }
                }
            }
        } else {
            let translationArr3 = self.translationFolderArr.first!.results
            if self.labelForDisplayAll.text == "表示" {
                for number in 0 ... translationArr3.count - 1 {
                    try! Realm().write {
                        translationArr3[number].isDisplayed = true
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "非表示"
                    }
                }
            } else {
                for number in 0 ... translationArr3.count - 1 {
                    try! Realm().write {
                        translationArr3[number].isDisplayed = false
                        try! Realm().add(translationArr3, update: .modified)
                        self.labelForDisplayAll.text = "表示"
                    }
                }
            }
        }
        self.tableView.reloadData()
        if self.indexPath_row != nil {
            self.tableView.scrollToRow(at: IndexPath(row: self.indexPath_row, section: 0), at: .middle, animated: true)
        }
    }

    //    学習記録ボタンが押された時にRecordViewControllerへ値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToHistory2ViewController" {
            let recordViewController = segue.destination as! RecordViewController
            recordViewController.studyViewController = self
            print("学習記録ボタンがおされた")

        } else if segue.identifier == "ToEditStudy" {
            let editStudyViewController = segue.destination as! EditStudyViewContoller

            editStudyViewController.inputDataTextView1 = self.translationFolderArr[0].results[self.sender_tag].inputData
            editStudyViewController.resultDataTextView2 = self.translationFolderArr[0].results[self.sender_tag].resultData
            editStudyViewController.translationId = self.translationFolderArr[0].results[self.sender_tag].id

            if self.searchBar.text != "" {
                editStudyViewController.inputDataTextView1 = self.translationArr[self.sender_tag].inputData
                editStudyViewController.resultDataTextView2 = self.translationArr[self.sender_tag].resultData
                editStudyViewController.translationId = self.translationArr[self.sender_tag].id
            }
        }
    }

    //    ボタンを押したら、次のcellへスクロール
    @IBAction func nextCellButton(_: Any) {
        if self.speechSynthesizer.isPaused || self.speechSynthesizer.isPaused != true && self.speechSynthesizer.isSpeaking != true {
            if self.indexPath_row < self.sections.count - 1 {
                if self.repeatButton.tintColor != .systemBlue {
                    self.speechSynthesizer.stopSpeaking(at: .immediate)
                }
                self.indexPath_row += 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                self.tableView.reloadData()
            }
        } else {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            if self.indexPath_row < self.sections.count - 1 {
                self.indexPath_row += 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                self.tableView.reloadData()
                if self.searchBar.text == "" {
                    speeche(textForResultData: self.translationFolderArr.first!.results[self.indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
                } else {
                    speeche(textForResultData: self.translationArr[self.indexPath_row].resultData, textForInputData: self.translationArr[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
                }
            }
        }
    }

    //    ボタンを押したら、一つ前のcellへスクロール
    @IBAction func backCellButton(_: Any) {
        if self.speechSynthesizer.isPaused || self.speechSynthesizer.isPaused != true && self.speechSynthesizer.isSpeaking != true {
            if self.indexPath_row > 0 {
                if self.repeatButton.tintColor != .systemBlue {
                    self.speechSynthesizer.stopSpeaking(at: .immediate)
                }
                self.indexPath_row -= 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                self.tableView.reloadData()
            }
        } else {
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            if self.indexPath_row > 0 {
                self.indexPath_row -= 1
                let indexPath = IndexPath(row: indexPath_row, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                self.tableView.reloadData()
                if self.searchBar.text == "" {
                    speeche(textForResultData: self.translationFolderArr.first!.results[self.indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
                } else {
                    speeche(textForResultData: self.translationArr[self.indexPath_row].resultData, textForInputData: self.translationArr[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
                }
            }
        }
    }

    //    音声一時停止/再生ボタン
    @IBAction func playButton(_: Any) {
        if self.speechSynthesizer.isPaused {
            setImage(self.playButton, "pause.circle.fill")
            self.speechSynthesizer.continueSpeaking()
            print("停止中")
        } else if self.speechSynthesizer.isSpeaking {
            setImage(self.playButton, "play.circle.fill")
            self.speechSynthesizer.pauseSpeaking(at: .immediate)
            print("おしゃべり中")
        } else if self.indexPath_row != nil {
            print("もう一度最初から再生")
            setImage(self.playButton, "pause.circle.fill")
            if self.searchBar.text == "" {
                speeche(textForResultData: self.translationFolderArr.first!.results[self.indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            } else {
                speeche(textForResultData: self.translationArr[self.indexPath_row].resultData, textForInputData: self.translationArr[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            }
        }
    }

    //    リピートボタン
    @IBAction func repeatButton(_: Any) {
        if self.indexPath_row != nil {
            if self.repeatButton.tintColor == .systemGray2 {
                self.repeatButton.tintColor = .systemBlue
                //                speeche(text: self.translationFolderArr[0].results[self.indexPath_row].resultData)
            } else {
                self.repeatButton.tintColor = .systemGray2
            }
        }
    }

    //    読み上げ速度
    @IBAction func speakSpeedButton(_: Any) {
        switch self.speakSpeed {
        case 0.5:
            self.speakSpeedButton.setTitle("1.25x", for: .normal)
            self.speakSpeed = 0.525
        case 0.525:
            self.speakSpeedButton.setTitle("1.5x", for: .normal)
            self.speakSpeed = 0.55
        case 0.55:
            self.speakSpeedButton.setTitle("1.75x", for: .normal)
            self.speakSpeed = 0.575
        case 0.575:
            self.speakSpeedButton.setTitle("2.0x", for: .normal)
            self.speakSpeed = 0.6
        case 0.6:
            self.speakSpeedButton.setTitle("0.5x", for: .normal)
            self.speakSpeed = 0.3
        case 0.3:
            self.speakSpeedButton.setTitle("0.75x", for: .normal)
            self.speakSpeed = 0.4
        case 0.4:
            self.speakSpeedButton.setTitle("1.0x", for: .normal)
            self.speakSpeed = 0.5
        default:
            print("nil")
        }
    }

    @IBAction func speakVoiceButton(_: Any) {
        switch self.voice {
        case "com.apple.ttsbundle.siri_Nicky_en-US_compact":
            self.voice = "com.apple.ttsbundle.siri_Aaron_en-US_compact"
            self.speakVoice.setTitle("男性", for: .normal)
        case "com.apple.ttsbundle.siri_Aaron_en-US_compact":
            self.voice = "com.apple.ttsbundle.siri_Nicky_en-US_compact"
            self.speakVoice.setTitle("女性", for: .normal)
        default:
            print("nil")
        }
    }

    //    com.apple.ttsbundle.siri_Aaron_en-US_compact
    //        com.apple.ttsbundle.siri_Nicky_en-US_compact
}

extension StudyViewController: ContextMenuDelegate {
    func contextMenuDidDeselect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt _: Int) {}

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
    func contextMenuDidSelect(_: ContextMenu,
                              cell _: ContextMenuCell,
                              targetedView _: UIView,
                              didSelect item: ContextMenuItem,
                              forRowAt index: Int) -> Bool
    {
        print("コンテキストメニューの", index, "番目のセルが選択された！")
        print("そのセルには", item.title, "というテキストが書いてあるよ!")

        switch index {
        case 0:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { () in
                self.performSegue(withIdentifier: "ToEditStudy", sender: nil)
            }
        case 1:
            self.savePhraseButton()
        case 2:
            let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForSelectFolder") as! UINavigationController
            let selectFolderForStrudyViewController = navigationController.viewControllers[0] as! SelectFolderForStudyViewContoller
            selectFolderForStrudyViewController.sender_tag = self.sender_tag

            if self.searchBar.text == "" {
                selectFolderForStrudyViewController.inputData = self.translationFolderArr.first!.results[self.sender_tag].inputData
                selectFolderForStrudyViewController.resultData = self.translationFolderArr.first!.results[self.sender_tag].resultData
                selectFolderForStrudyViewController.inputAndResultData = self.translationFolderArr.first!.results[self.sender_tag].inputAndResultData
            } else {
                selectFolderForStrudyViewController.inputData = self.translationArr[self.sender_tag].inputData
                selectFolderForStrudyViewController.resultData = self.translationArr[self.sender_tag].resultData
                selectFolderForStrudyViewController.inputAndResultData = self.translationArr[self.sender_tag].inputAndResultData
            }

            if let sheet = navigationController.sheetPresentationController {
                sheet.detents = [.medium()]
                present(navigationController, animated: true, completion: nil)
            }

        case 3:
            print("コピーボタン")
            self.copyButton()
        case 4:
            self.deleteButton()
        default:
            print("他の値")
        }

        // サンプルではtrueを返していたのでとりあえずtrueを返してみる
        return true
    }

    /**
     コンテキストメニューが表示されたら呼ばれる
     */
    func contextMenuDidAppear(_: ContextMenu) {
        print("コンテキストメニューが表示された!")
    }

    /**
     コンテキストメニューが消えたら呼ばれる
     */
    func contextMenuDidDisappear(_: ContextMenu) {
        print("コンテキストメニューが消えた!")
    }

    func copyButton() {
        if self.searchBar.text != "" {
            UIPasteboard.general.string = self.translationArr[self.sender_tag].inputAndResultData
        } else {
            UIPasteboard.general.string = self.translationFolderArr[0].results[self.sender_tag].inputAndResultData
        }
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    func deleteButton() {
        let alert = UIAlertController(title: "本当に削除しますか？", message: "保存した文章を\n左スワイプで削除することもできます", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
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
            self.repeatButton.tintColor = .systemGray2
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            self.nextCellButton.isEnabled = false
            self.backCellButton.isEnabled = false
            self.playButton.isEnabled = false
            self.tableView.reloadData()
        })

        let cencel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in print("キャンセルボタンがタップされた。")
        })

        alert.addAction(delete)
        alert.addAction(cencel)

        present(alert, animated: true, completion: nil)
    }

    //    右のドキュメントシステムアイコンをタップしたら、Realm（TranslationFolderファイル）のRecord2クラスに書き込み保存
    func savePhraseButton() {
        if self.searchBar.text != "" {
            self.inputData3 = self.translationArr[self.sender_tag].inputData
            self.resultData3 = self.translationArr[self.sender_tag].resultData
        } else {
            self.inputData3 = self.translationFolderArr[0].results[self.sender_tag].inputData
            self.resultData3 = self.translationFolderArr[0].results[self.sender_tag].resultData
        }

        let phraseWord = PhraseWord()
        let date5 = Date()

        phraseWord.inputData = self.inputData3
        phraseWord.resultData = self.resultData3
        phraseWord.date = date5

        let phraseWordArr = self.realm.objects(PhraseWord.self)
        if phraseWordArr.count != 0 {
            phraseWord.id = phraseWordArr.max(ofProperty: "id")! + 1
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(phraseWord)
            }
        } catch {
            print("エラー")
        }
        SVProgressHUD.showSuccess(withStatus: "'お気に入り'へ保存しました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @IBAction func backButtton(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
        //        .deleteだけでもよき
    }

    //    セル削除メソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            try! self.realm.write {
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
            self.repeatButton.tintColor = .systemGray2
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            self.nextCellButton.isEnabled = false
            self.backCellButton.isEnabled = false
            self.playButton.isEnabled = false
            tableView.reloadData()
        }
    }
}

// try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//    }
// }

extension StudyViewController: LongPressDetectionDelegate, AVSpeechSynthesizerDelegate {
    func playBackground() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
    }

    func longPressDetection(_ indexPath_row: Int, _ cell: CustomCellForStudy) {
        self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        if self.searchBar.text == "" {
            self.speeche(textForResultData: self.translationFolderArr.first!.results[indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
        } else {
            self.speeche(textForResultData: self.translationArr[indexPath_row].resultData, textForInputData: self.translationArr[indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
        }

        self.playButton.isEnabled = true
        self.backCellButton.isEnabled = true
        self.nextCellButton.isEnabled = true

        self.indexPath_row = indexPath_row
        let indexPath = IndexPath(row: indexPath_row, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)

        cell.backgroundColor = .white

        cell.backgroundColor = .systemGray6

        self.nextCellButton.isEnabled = true
        self.backCellButton.isEnabled = true

        self.label1.text = " "

        self.tableView.reloadData()
    }

    func speeche(textForResultData: String, textForInputData: String, speakSpeed: Float, voice: String) {
        let speak = self.realm.objects(Speak.self).first!
        if speak.playResultData {
            let utterance = AVSpeechUtterance(string: textForResultData) // 読み上げる文字
            utterance.voice = self.makeVoice(voice) // 言語
            utterance.rate = speakSpeed // 読み上げ速度
            self.speechSynthesizer.delegate = self
            self.speechSynthesizer.speak(utterance)
        } else if speak.playInputData {
            print("inputData音声再生が実行された")
            let utterance = AVSpeechUtterance(string: textForInputData) // 読み上げる文字
            utterance.voice = self.makeVoice(voice) // 言語
            utterance.rate = speakSpeed // 読み上げ速度
            self.speechSynthesizer.delegate = self
            self.speechSynthesizer.speak(utterance)
        }
    }

    // 英語ボイスの生成　Siri
    func makeVoice(_ identifier: String) -> AVSpeechSynthesisVoice! {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.identifier == identifier {
                return AVSpeechSynthesisVoice(identifier: identifier)
            }
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    func setImage(_ button: UIButton, _ string: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
        button.setImage(UIImage(systemName: string, withConfiguration: config), for: .normal)
    }

    //    読み上げ開始
    internal func speechSynthesizer(_: AVSpeechSynthesizer, didStart _: AVSpeechUtterance) {
        print("読み上げ開始")
        self.setImage(self.playButton, "pause.circle.fill")
    }

    // 読み上げ終了
    internal func speechSynthesizer(_: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
        print("読み上げ終了")

        if self.repeatButton.tintColor == .systemBlue {
            if self.searchBar.text == "" {
                self.speeche(textForResultData: self.translationFolderArr.first!.results[self.indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            } else {
                self.speeche(textForResultData: self.translationArr[self.indexPath_row].resultData, textForInputData: self.translationArr[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            }
        } else {
            self.setImage(self.playButton, "play.circle.fill")
        }
    }

    //    読み上げ一時停止した時
    internal func speechSynthesizer(_: AVSpeechSynthesizer, didPause _: AVSpeechUtterance) {}

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        print("呼ばれた")
        self.repeatButton.tintColor = .systemGray2
        self.speechSynthesizer.stopSpeaking(at: .immediate)
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
// }

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
// }
