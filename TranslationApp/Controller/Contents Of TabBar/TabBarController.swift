//
//  TabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

// プロフィール画像処理
// 絞り込み表示にて、whererFieldは使えるのか？機能がないと思う
// profileモデルクラス
// パスワードリセット確認メールの送信がされていない
// 実機での実行ができていない（アップデートの必要性がある）

import RealmSwift
import SVProgressHUD
import UIKit

class TabBarController: UITabBarController {
    var tabBarController1: UITabBarController!
    private let realm = try! Realm()
    private var translationFolder: TranslationFolder!
    private var folderNameArr = [String]()

    // limited number of characters
    private var maxCharactersLength: Int = 13

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarAppearence()
        self.giveTabBarControllerToEachOfViewControllers()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
    }

    private func setNavigationBarAppearence() {
        let appearance1 = UINavigationBarAppearance()
        appearance1.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance1
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance1

        self.selectedIndex = 2
        // the color of the tab icon
        tabBar.tintColor = UIColor.systemBlue
        // settings for backGround color
        let appearance2 = UITabBarAppearance()
        appearance2.backgroundColor = UIColor.systemGray6
        tabBar.standardAppearance = appearance2
        tabBar.scrollEdgeAppearance = appearance2
    }

    private func giveTabBarControllerToEachOfViewControllers() {
        let navigationController0 = viewControllers![0] as! UINavigationController
        let historyViewController = navigationController0.viewControllers[0] as! HistoryViewController
        historyViewController.tabBarController1 = self

        let navigationController1 = viewControllers![1] as! UINavigationController
        let folderViewController = navigationController1.viewControllers[0] as! FolderViewController
        folderViewController.tabBarController1 = self

        let navigationController2 = viewControllers![2] as! UINavigationController
        let translateViewController = navigationController2.viewControllers[0] as! TranslateViewController
        translateViewController.tabBarController1 = self

        let navigationController3 = viewControllers![3] as! UINavigationController
        let pagingPhraseWordViewController = navigationController3.viewControllers[0] as! PagingPhraseWordViewController
        pagingPhraseWordViewController.tabBarController1 = self

        let navigationController4 = viewControllers![4] as! UINavigationController
        let recordViewController = navigationController4.viewControllers[0] as! RecordViewController
        recordViewController.tabBarController1 = self
    }

    // access in TranslateViewController
    public func setStringToNavigationItemTitle0() {
        navigationItem.title = "翻訳"
    }

    // access in FolderViewController
    public func setStringToNavigationItemTitle1() {
        navigationItem.title = "フォルダー"
    }

    // access in HistoryViewController
    public func setStringToNavigationItemTitle2() {
        navigationItem.title = "履歴"
    }

    // access in RecodViewController
    public func setStringToNavigationItemTitle3() {
        navigationItem.title = "学習記録"
    }

    // access in PhraseWordViewController
    public func setStringToNavigationItemTitle4() {
        navigationItem.title = "お気に入り"
    }

    // called when a new folder is created while FolderViewController screen is displayed
    func tableViewReload() {
        //        「１」represents folderViewController
        if selectedIndex == 1 {
            let navigationController = viewControllers![1] as! UINavigationController
            let folderViewController = navigationController.viewControllers[0] as! FolderViewController
            folderViewController.tableView.reloadData()
        }
    }

    // called when the button is tapped on the upper right corner of the screen
    @IBAction func button(_: Any) {
        self.createFolder()
    }

    func createFolder() {
        let alert = UIAlertController(title: "新規フォルダー作成", message: "フォルダーを作成してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addTextField { textField in
            textField.placeholder = "フォルダー名"
            textField.textAlignment = .center
            textField.delegate = self
        }
        alert.addAction(UIAlertAction(title: "作成", style: .default, handler: { _ in

            if let textField_text = alert.textFields?.first?.text {
                let textField_text = textField_text.trimmingCharacters(in: .whitespaces)
                let translationFolderArr = self.realm.objects(TranslationFolder.self)
                // if the retrived data is not empty
                if translationFolderArr.isEmpty != true {
                    self.folderNameArr = []
                    translationFolderArr.forEach { translationFolder in
                        self.folderNameArr.append(translationFolder.folderName)
                    }
                }

                self.determineIfTheNewFileCanBeCreated(textField_text: textField_text, completion: { () in
                    self.wrtieFolderNameToDatabase(textField_text: textField_text)
                    self.tableViewReload()
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    // determine if the new file can be created
    private func determineIfTheNewFileCanBeCreated(textField_text: String, completion: @escaping () -> Void) {
        // if nothing is entered
        if textField_text.isEmpty {
            SVProgressHUD.showError(withStatus: "フォルダー名を入力してください")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
                // if there is a folder with the same name as the one you attempt to create
        } else if self.folderNameArr.contains(textField_text) {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "同じフォルダー名は作成できません")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        // if both of the above 2 conditions are not met (satisfied), implement closure whose process is descrebed right below this one
        completion()
    }

    // process called as a closure for writing folderName to Realm database
    private func wrtieFolderNameToDatabase(textField_text: String) {
        // a folder cannot be created with the same name and with no characters
        if self.folderNameArr.contains(textField_text) != true, textField_text != "" {
            self.translationFolder = TranslationFolder()
            let allTranslationFolder = self.realm.objects(TranslationFolder.self)
            // set the value to the id that is the primary key so that id doesn't cover any of the id
            if allTranslationFolder.count != 0 {
                self.translationFolder.id = allTranslationFolder.max(ofProperty: "id")! + 1
            }

            // wrtie to Realm DataBase
            try! self.realm.write {
                self.translationFolder.folderName = textField_text
                self.translationFolder.date = Date()
                self.realm.add(self.translationFolder)
            }

            SVProgressHUD.showSuccess(withStatus: "新規フォルダー\n'\(textField_text)'\nを作成しました。")
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
    }

    // when excuting a transition to timeline screeen
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToSecondTabBarController" {
            let secondTabBarController = segue.destination as! SecondTabBarController

            // pass the SecondTabBarController instance to each of specified viewControllers which are described below
            let navigationController = secondTabBarController.viewControllers![1] as! UINavigationController
            let profileViewController = navigationController.viewControllers[0] as! ProfileViewController
            profileViewController.secondTabBarController = secondTabBarController

            let navigationController1 = secondTabBarController.viewControllers![0] as! UINavigationController
            let secondPagingViewController = navigationController1.viewControllers[0] as! SecondPagingViewController
            secondPagingViewController.secondTabBarController = secondTabBarController

            let navigationController2 = secondTabBarController.viewControllers![2] as! UINavigationController
            let chatListViewController = navigationController2.viewControllers[0] as! ChatListViewController
            chatListViewController.secondTabBarController = secondTabBarController
        }
    }
}

extension TabBarController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // run each time the selection in the textField is changed
        // regulate maximun number of characters and spaces in the textField
        guard let textField_text = textField.text else { return }
        if textField_text.count > self.maxCharactersLength {
            textField.text = String(textField_text.prefix(self.maxCharactersLength))
        }
    }
}

// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
