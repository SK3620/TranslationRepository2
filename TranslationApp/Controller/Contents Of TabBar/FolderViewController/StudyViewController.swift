
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

class StudyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet private var tableView: UITableView!

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var displayAllButton: UIButton!
    @IBOutlet private var labelForDisplayAll: UILabel!
    @IBOutlet private var repeatButton: UIButton!
    @IBOutlet private var label1: UILabel!

    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var backCellButton: UIButton!
    @IBOutlet private var nextCellButton: UIButton!
    @IBOutlet private var speakSpeedButton: UIButton!
    @IBOutlet private var speakVoice: UIButton!

    private let realm = try! Realm()
    private var translationFolderArr: Results<TranslationFolder>!
    private var translationArr: Results<Translation>!

    var tabBarController1: TabBarController!

    var folderNameString: String = ""

    private var inputDataArr = [String]()
    private var resultDataArr = [String]()

    var sender_tag: Int!

    var indexPath_row: Int!

    private var menuNavigationController: SideMenuNavigationController!

    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speakSpeed: Float = 0.5
    private var voice: String = "com.apple.ttsbundle.siri_Nicky_en-US_compact"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)

        self.speakSpeedButton.setTitle("1.0x", for: .normal)
        self.speakVoice.setTitle("女性", for: .normal)

        // navigationBar settings
        self.setNavigationBar()

        // button design settings
        self.setImage(self.playButton, "play.circle.fill")
        self.setImage(self.nextCellButton, "arrowtriangle.right")
        self.setImage(self.backCellButton, "arrowtriangle.left")
        self.setImage(self.displayAllButton, "arrow.triangle.2.circlepath")
        self.setImage(self.repeatButton, "repeat")

        // some settings for tableView and searchbar
        self.settingsForTableViewAndSearchBar()

        // installation of done bar on keyboard
        self.setDoneOnKeyboard()
    }

    // navigationBar settings
    private func setNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearence
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearence
    }

    // button desgin settings
    private func setImage(_ button: UIButton, _ string: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .default)
        button.setImage(UIImage(systemName: string, withConfiguration: config), for: .normal)
    }

    // some settings for tableView and searchbar
    private func settingsForTableViewAndSearchBar() {
        //        registration of xib file
        let nib = UINib(nibName: "CustomCellForStudy", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCellForStudy")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = .clear
        self.tableView.allowsSelection = false
        self.tableView.layer.cornerRadius = 10

        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.enablesReturnKeyAutomatically = false
    }

    // installation of done bar on keyboard
    private func setDoneOnKeyboard() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTapped))
        doneToolbar.items = [spacer, doneButton]
        self.searchBar.inputAccessoryView = doneToolbar
    }

    // when the done button is tapped
    @objc func doneButtonTapped(sender _: UIButton) {
        self.searchBar.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        // Enable background playback
        // this method is described in extension part
        self.playBackground()

        self.settingsForNavigationControllerAndBar()

        self.appendInputDataAndResultDataToArray()

        if self.searchBar.text != "" {
            // do a string search
            self.search()
        }

        self.repeatButton.tintColor = .systemGray2
        self.labelForDisplayAll.text = "表示"
        self.title = self.folderNameString

        if self.indexPath_row == nil {
            self.label1.text = "文章を長押しで音声再生"
            self.label1.textColor = .orange
            self.nextCellButton.isEnabled = false
            self.backCellButton.isEnabled = false
        } else {
            self.nextCellButton.isEnabled = true
            self.backCellButton.isEnabled = true
        }
    }

    private func settingsForNavigationControllerAndBar() {
        // settings for navigationController of TabBarController
        self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)

        // settings for navigationController of self
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationController!.navigationBar.backgroundColor = .systemGray4
        self.navigationController!.navigationBar.barTintColor = .systemGray4
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(self.settingsBarButtonItemTapped(_:)))
        self.navigationItem.rightBarButtonItems = [settingsBarButtonItem]
        // a process when settingsBarButtonItem is tapped is described in <extension StudyViewController: SettingsDelegate{}>
    }

    private func appendInputDataAndResultDataToArray() {
        self.inputDataArr = []
        self.resultDataArr = []

        // retrive specified data whose folder name is equal to self.folderNameString to which was passed studyViewController from folderViewController
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        let predicate = NSPredicate(format: "folderName == %@", self.folderNameString)
        self.translationFolderArr = self.translationFolderArr.filter(predicate)
        self.translationFolderArr[0].results.forEach {
            self.inputDataArr.append($0.inputData)
            self.resultDataArr.append($0.resultData)
        }
        self.tableView.reloadData()
    }

    func hideNavigationControllerOfTabBarController() {
        self.tabBarController1.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // when the search button is tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    // called each time any characters are entered in the search bar
    func searchBar(_: UISearchBar, textDidChange _: String) {
        self.search()
    }

    // do a string search
    func search() {
        self.speechSynthesizer.pauseSpeaking(at: .immediate)
        self.playButton.isEnabled = false
        self.setImage(self.playButton, "play.circle.fill")
        self.backCellButton.isEnabled = false
        self.nextCellButton.isEnabled = false
        self.label1.text = "文章を長押しで音声再生"

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        let predicate = NSPredicate(format: "folderName == %@", folderNameString)
        self.translationFolderArr = self.translationFolderArr.filter(predicate)
        // if the results have no data, return
        if self.translationFolderArr.first!.results.count == 0 {
            return
        }
        self.inputDataArr.removeAll()
        self.resultDataArr.removeAll()

        // if no characters are entered in the search bar, display all data
        if self.searchBar.text == "" {
            self.displayAllData()
        } else {
            // do a filter search
            self.doFilterSearch()
        }
        self.tableView.reloadData()
    }

    private func displayAllData() {
        self.displayAllButton.isEnabled = true

        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        let predicate = NSPredicate(format: "folderName == %@", folderNameString)
        self.translationFolderArr = self.translationFolderArr.filter(predicate)
        self.translationFolderArr[0].results.forEach {
            self.inputDataArr.append($0.inputData)
            self.resultDataArr.append($0.resultData)
        }
    }

    private func doFilterSearch() {
        self.displayAllButton.isEnabled = false

        let filteredResults = self.translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        self.translationArr = self.translationFolderArr[0].results.filter("inputAndResultData CONTAINS '\(self.searchBar.text!)'")
        if filteredResults.count != 0 {
            self.indexPath_row = 0
            filteredResults.forEach {
                self.inputDataArr.append($0.inputData)
                self.resultDataArr.append($0.resultData)
            }
        } else {
            self.playButton.isEnabled = false
            self.backCellButton.isEnabled = false
            self.nextCellButton.isEnabled = false
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.translationFolderArr.first!.results.isEmpty {
            self.displayAllButton.isEnabled = false
        }
        return self.resultDataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellForStudy", for: indexPath) as! CustomCellForStudy
        cell.indexPath_row = indexPath.row
        // delegate a process to self when a cell is pressed and held
        cell.delegate = self
        cell.customCellForStudy = cell

        // implemented when a cell is tapped and held
        // by being tapped and held, longPressDetectionDelegateMethod is called and tapped 'indexPath.row' is stored in the variable self.indexPath_row
        if indexPath.row == self.indexPath_row {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .white
        }

        // display the contents in each cell
        cell.setData(self.inputDataArr[indexPath.row], indexPath.row)

        // determine if a star should be marked or not
        self.determineIfStarShouldBeMarked(cell: cell, indexPath: indexPath)

        // determine if the resultData should be displayed or not
        self.determineIfTheResultDataShouldBeDisplayed(cell: cell, indexPath: indexPath)

        // chackmark represents a star mark
        // when tapped, change a icon image and write to Realm database
        cell.checkMarkButton.tag = indexPath.row
        cell.checkMarkButton.addTarget(self, action: #selector(self.tappedCheckMarkButton(_:)), for: .touchUpInside)

        // there are two displayButtons to display resultData text and both these two buttons have the same function (when they are tapped, just display resultData and write to database wheather or not the cell is displayed)
        cell.displayButton1.tag = indexPath.row
        cell.displayButton1.addTarget(self, action: #selector(self.tappdDisplayButton(_:)), for: .touchUpInside)
        cell.displayButton2.tag = indexPath.row
        cell.displayButton2.addTarget(self, action: #selector(self.tappdDisplayButton(_:)), for: .touchUpInside)

        // display a context menu when tapped
        cell.cellEditButton.tag = indexPath.row
        cell.cellEditButton.addTarget(self, action: #selector(self.tappdCellEditButton(_:)), for: .touchUpInside)

        cell.memoButton.tag = indexPath.row
        cell.memoButton.addTarget(self, action: #selector(self.tappedMemoButton(_:)), for: .touchUpInside)

        // maintain a cell layout by inserting text on label2.text if resultData on each cell has no characters
        self.maintainCellLayout(cell: cell, indexPath: indexPath)

        return cell
    }

    private func determineIfStarShouldBeMarked(cell: CustomCellForStudy, indexPath: IndexPath) {
        var result: Int
        if self.searchBar.text != "" {
            result = self.translationArr[indexPath.row].isChecked
        } else {
            result = self.translationFolderArr.first!.results[indexPath.row].isChecked
        }

        switch result {
        case 0:
            cell.setImage(cell.checkMarkButton, "star")
        case 1:
            cell.setImage(cell.checkMarkButton, "star.leadinghalf.filled")
        case 2:
            cell.setImage(cell.checkMarkButton, "star.fill")
        default:
            print("その他の値です")
        }
    }

    private func determineIfTheResultDataShouldBeDisplayed(cell: CustomCellForStudy, indexPath: IndexPath) {
        print("display実行")
        var isDisplayed: Bool
        if self.searchBar.text != "" {
            isDisplayed = self.translationArr[indexPath.row].isDisplayed
        } else {
            isDisplayed = self.translationFolderArr.first!.results[indexPath.row].isDisplayed
        }
        switch isDisplayed {
        case false:
            cell.displayButton2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            cell.cellEditButton.isEnabled = true
            if indexPath.row == 0 {
                cell.label2.text = ""
                let image = UIImage(systemName: "hand.tap")
                cell.displayButton2.setImage(image, for: .normal)
            } else if indexPath.row != 0 {
                let image = UIImage()
                cell.displayButton2.setImage(image, for: .normal)
                cell.label2.text = ""
            }
            cell.centerLine.backgroundColor = UIColor.clear
        case true:
            cell.cellEditButton.isEnabled = true
            cell.displayButton2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            let image1 = UIImage()
            cell.displayButton2.setImage(image1, for: .normal)
            cell.setData2(self.resultDataArr[indexPath.row])
            cell.centerLine.backgroundColor = UIColor.systemGray5
        }
    }

    private func maintainCellLayout(cell: CustomCellForStudy, indexPath: IndexPath) {
        if self.translationFolderArr.first?.results[indexPath.row].resultData == "" {
            cell.label2.text = ""
        }
        if self.searchBar.text != "", self.translationArr[indexPath.row].resultData == "" {
            cell.label2.text = ""
        }
    }

    @objc func tappedMemoButton(_ sender: UIButton) {
        let secondMemoForStudyViewController = storyboard?.instantiateViewController(withIdentifier: "SecondMemoView") as! SecondMemoForStudyViewController
        if let sheet = secondMemoForStudyViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        secondMemoForStudyViewController.translationId = self.translationFolderArr[0].results[sender.tag].id
        secondMemoForStudyViewController.memo = self.translationFolderArr[0].results[sender.tag].secondMemo

        if self.searchBar.text != "" {
            secondMemoForStudyViewController.translationId = self.translationArr[sender.tag].id
            secondMemoForStudyViewController.memo = self.translationArr[sender.tag].secondMemo
        }
        present(secondMemoForStudyViewController, animated: true, completion: nil)
    }

    @objc func tappedCheckMarkButton(_ sender: UIButton) {
        // if any characters are entered in the seachbar
        if self.searchBar.text != "" {
            let isChecked = self.translationArr[sender.tag].isChecked
            switch isChecked {
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
                print("nil")
            }
        } else {
            let translationArr = self.translationFolderArr.first!.results
            let isChecked = translationArr[sender.tag].isChecked
            switch isChecked {
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
                print("nil")
            }
        }
        self.tableView.reloadData()
    }

    @objc func tappdDisplayButton(_ sender: UIButton) {
        if self.searchBar.text != "" {
            let isDisplayed = self.translationArr[sender.tag].isDisplayed
            switch isDisplayed {
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
            let translationArr = self.translationFolderArr.first!.results
            let isDisplayed = translationArr[sender.tag].isDisplayed
            switch isDisplayed {
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
        }
        self.tableView.reloadData()
    }

    // display all resultData
    @IBAction func displayAllButton(_: Any) {
        let translationArr = self.translationFolderArr.first!.results
        if self.labelForDisplayAll.text == "表示" {
            print("表示")
            self.labelForDisplayAll.text = "非表示"
            translationArr.forEach { translation in
                try! Realm().write {
                    translation.isDisplayed = true
                    try! Realm().add(translationArr, update: .modified)
                }
            }
        } else if self.labelForDisplayAll.text == "非表示" {
            self.labelForDisplayAll.text = "表示"
            translationArr.forEach { translation in
                try! Realm().write {
                    translation.isDisplayed = false
                    try! Realm().add(translationArr, update: .modified)
                }
            }
        }
        self.tableView.reloadData()

        // scroll
        if self.indexPath_row != nil {
            self.tableView.scrollToRow(at: IndexPath(row: self.indexPath_row, section: 0), at: .middle, animated: true)
        }
    }

    // display a context menu
    @objc func tappdCellEditButton(_ sender: UIButton) {
        let edit = ContextMenuItemWithImage(title: "編集する", image: UIImage(systemName: "square.and.pencil")!)
        let save = ContextMenuItemWithImage(title: "お気に入りにする", image: UIImage(systemName: "heart")!)
        let folder = ContextMenuItemWithImage(title: "保存先を変更する", image: UIImage(systemName: "folder")!)
        let copy = ContextMenuItemWithImage(title: "コピーする", image: UIImage(systemName: "doc.on.doc")!)
        let delete = ContextMenuItemWithImage(title: "削除する", image: UIImage(systemName: "trash")!)

        let cellForRow = IndexPath(row: sender.tag, section: 0)
        // store the information of the tapped indexPath
        self.sender_tag = sender.tag

        CM.items = [edit, save, folder, copy, delete]
        CM.showMenu(viewTargeted: self.tableView.cellForRow(at: cellForRow)!, delegate: self, animated: true)
    }

    // Pass the value to RecordViewController when the record learning button is tapped
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToHistory2ViewController" {
            let recordViewController = segue.destination as! RecordViewController
            recordViewController.studyViewController = self
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

    // scroll to the next cell when tapped
    @IBAction func nextCellButton(_: Any) {
        if self.speechSynthesizer.isPaused || self.speechSynthesizer.isPaused != true && self.speechSynthesizer.isSpeaking != true {
            if self.indexPath_row < self.inputDataArr.count - 1 {
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
            if self.indexPath_row < self.resultDataArr.count - 1 {
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

    // scroll to the previous cell when tapped
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

    // Audio pause/playback button
    @IBAction func playButton(_: Any) {
        if self.speechSynthesizer.isPaused {
            self.setImage(self.playButton, "pause.circle.fill")
            self.speechSynthesizer.continueSpeaking()
        } else if self.speechSynthesizer.isSpeaking {
            self.setImage(self.playButton, "play.circle.fill")
            self.speechSynthesizer.pauseSpeaking(at: .immediate)
        } else if self.indexPath_row != nil {
            self.setImage(self.playButton, "pause.circle.fill")
            if self.searchBar.text == "" {
                speeche(textForResultData: self.translationFolderArr.first!.results[self.indexPath_row].resultData, textForInputData: self.translationFolderArr.first!.results[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            } else {
                speeche(textForResultData: self.translationArr[self.indexPath_row].resultData, textForInputData: self.translationArr[self.indexPath_row].inputData, speakSpeed: self.speakSpeed, voice: self.voice)
            }
        }
    }

    //    repeat button
    @IBAction func repeatButton(_: Any) {
        if self.indexPath_row != nil {
            if self.repeatButton.tintColor == .systemGray2 {
                self.repeatButton.tintColor = .systemBlue
            } else {
                self.repeatButton.tintColor = .systemGray2
            }
        }
    }

    //    reading speed
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

    // male voice or female voice
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
                              didSelect _: ContextMenuItem,
                              forRowAt index: Int) -> Bool
    {
        switch index {
        case 0:
            // screen transition to EditStudyVC
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

    // After tapping the document system icon on the right, write and save to the PhraseWord class of the Realm
    func savePhraseButton() {
        var inputData: String
        var resultData: String

        // if any characters are entered in the search bar
        // self.sender_tag stores the infromation of the tapped indexPath
        if self.searchBar.text != "" {
            inputData = self.translationArr[self.sender_tag].inputData
            resultData = self.translationArr[self.sender_tag].resultData
        } else {
            inputData = self.translationFolderArr[0].results[self.sender_tag].inputData
            resultData = self.translationFolderArr[0].results[self.sender_tag].resultData
        }
        let phraseWord = PhraseWord()
        phraseWord.inputData = inputData
        phraseWord.resultData = resultData
        phraseWord.date = Date()

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

    // a process to delete data
    func deleteButton() {
        let alert = UIAlertController(title: "本当に削除しますか？", message: "保存した文章を\n左スワイプで削除することもできます", preferredStyle: .alert)
        let cencel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in print("キャンセルボタンがタップされた。") })
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            try! self.realm.write {
                if self.searchBar.text != "" {
                    self.realm.delete(self.translationArr[self.sender_tag])
                    self.inputDataArr.remove(at: self.sender_tag)
                    self.resultDataArr.remove(at: self.sender_tag)
                } else {
                    self.realm.delete(self.translationFolderArr[0].results[self.sender_tag])
                    self.inputDataArr.remove(at: self.sender_tag)
                    self.resultDataArr.remove(at: self.sender_tag)
                }
            }
            self.repeatButton.tintColor = .systemGray2
            self.speechSynthesizer.stopSpeaking(at: .immediate)
            self.nextCellButton.isEnabled = false
            self.backCellButton.isEnabled = false
            self.playButton.isEnabled = false
            self.tableView.reloadData()
        })
        alert.addAction(delete)
        alert.addAction(cencel)
        present(alert, animated: true, completion: nil)
    }

    // copy
    func copyButton() {
        if self.searchBar.text != "" {
            UIPasteboard.general.string = self.translationArr[self.sender_tag].inputAndResultData
        } else {
            UIPasteboard.general.string = self.translationFolderArr[0].results[self.sender_tag].inputAndResultData
        }
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    @IBAction func backButtton(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            try! self.realm.write {
                if self.searchBar.text != "" {
                    self.realm.delete(translationArr[indexPath.row])
                    inputDataArr.remove(at: indexPath.row)
                    resultDataArr.remove(at: indexPath.row)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                    self.realm.delete(self.translationFolderArr[0].results[indexPath.row])
                    inputDataArr.remove(at: indexPath.row)
                    resultDataArr.remove(at: indexPath.row)
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

        cell.backgroundColor = .systemGray6

        self.nextCellButton.isEnabled = true
        self.backCellButton.isEnabled = true

        self.label1.text = " "

        self.tableView.reloadData()
    }

//    read out
    func speeche(textForResultData: String, textForInputData: String, speakSpeed: Float, voice: String) {
        let speak = self.realm.objects(Speak.self).first!
        if speak.playResultData {
            let utterance = AVSpeechUtterance(string: textForResultData) // characters to be read out
            utterance.voice = self.makeVoice(voice) // language
            utterance.rate = speakSpeed // speaking speed
            self.speechSynthesizer.delegate = self
            self.speechSynthesizer.speak(utterance)
        } else if speak.playInputData {
            let utterance = AVSpeechUtterance(string: textForInputData)
            utterance.voice = self.makeVoice(voice)
            utterance.rate = speakSpeed
            self.speechSynthesizer.delegate = self
            self.speechSynthesizer.speak(utterance)
        }
    }

    // english Siri voice
    func makeVoice(_ identifier: String) -> AVSpeechSynthesisVoice! {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.identifier == identifier {
                return AVSpeechSynthesisVoice(identifier: identifier)
            }
        }
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    //    start of reading out
    internal func speechSynthesizer(_: AVSpeechSynthesizer, didStart _: AVSpeechUtterance) {
        self.setImage(self.playButton, "pause.circle.fill")
    }

    // end of reading out
    internal func speechSynthesizer(_: AVSpeechSynthesizer, didFinish _: AVSpeechUtterance) {
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

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.repeatButton.tintColor = .systemGray2
        self.speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

// called when a cell in SettingsForStrudyViewController is tapped as a delegate method
// a process when tapped is delegated to StudyViewController
protocol SettingsDelegate: AnyObject {
    func tappedSettingsItem(indexPath: IndexPath)
}

extension StudyViewController: SettingsDelegate {
    // settings for side menu
    private func makeSettings() -> SideMenuSettings {
        var settings = SideMenuSettings()
        // specify action
        settings.presentationStyle = .menuSlideIn
        settings.menuWidth = 170
        // transparency of the status bar
        settings.statusBarEndAlpha = 0
        return settings
    }

    // called when the bar button item on the upper right corner is tapped
    @objc func settingsBarButtonItemTapped(_: UIBarButtonItem) {
        let menuViewController = storyboard?.instantiateViewController(withIdentifier: "Menu") as! SettingsForStudyViewController
        menuViewController.delegate = self
        // configure navigationController for side menu
        self.menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)

        self.menuNavigationController.leftSide = false
        self.menuNavigationController.settings = self.makeSettings()
        // adding as right side menu
        SideMenuManager.default.rightMenuNavigationController = self.menuNavigationController

        present(self.menuNavigationController, animated: true, completion: nil)
    }

    func tappedSettingsItem(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("タップ0")
            // when お気に入り in the cell is tapped
            // screen transition to PhraseWordViewController
            self.screenTransitionToPhraseWordVC()
        case 1:
            // when 学習記録 in the cell is tapped
            // screen transition to RecordViewController
            self.screenTransitionToRecordVC()
        case 2:
            // when メモ in the cell is tapped
            // screen transition to MemoForStudyViewController
            self.screenTransitionToMemoForStudyVC()
        case 3:
            // when 太文字再生 in the cell is tapped
            self.whenBoldfaceIsTapped()
        case 4:
            // when 小文字再生 in the cell is tapped
            self.whenLowerfaceIsTapped()
        default:
            print("nil")
        }
    }

    private func screenTransitionToPhraseWordVC() {
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForPhraseWord") as! UINavigationController
        let pagingPharseWordViewController = navigationController.viewControllers[0] as! PagingPhraseWordViewController
        pagingPharseWordViewController.setItemsOnNavigationBar()
        pagingPharseWordViewController.studyViewController = self
        pagingPharseWordViewController.tabBarController1 = self.tabBarController1
        present(navigationController, animated: true, completion: nil)
    }

    private func screenTransitionToRecordVC() {
        let navigationController = storyboard?.instantiateViewController(withIdentifier: "NVCForRecordView") as! UINavigationController
        let recordViewController = navigationController.viewControllers[0] as! RecordViewController
        recordViewController.tabBarController1 = self.tabBarController1
        recordViewController.studyViewController = self
        recordViewController.setItemsOnNaviationBar()
        present(navigationController, animated: true, completion: nil)
    }

    private func screenTransitionToMemoForStudyVC() {
        let memoForStudyViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoForStudyViewController
        if let sheet = memoForStudyViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        memoForStudyViewController.folderNameString = self.folderNameString
        present(memoForStudyViewController, animated: true, completion: nil)
    }

    private func whenBoldfaceIsTapped() {
        self.repeatButton.tintColor = .systemGray2
        self.speechSynthesizer.stopSpeaking(at: .immediate)
        self.setImage(self.playButton, "play.circle.fill")
    }

    private func whenLowerfaceIsTapped() {
        self.repeatButton.tintColor = .systemGray2
        self.speechSynthesizer.stopSpeaking(at: .immediate)
        self.setImage(self.playButton, "play.circle.fill")
    }
}
