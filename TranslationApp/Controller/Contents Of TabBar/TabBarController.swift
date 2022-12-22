//
//  TabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

// プロフィール画像処理
// 絞り込み表示にて、whererFieldは使えるのか？機能がないと思う
// profileモデルクラス
// コメント削除時にコメント数が反映されない（データ削除時に起こるいいね数の反映はしなくていい）🟠
// パスワードリセット確認メールの送信がされていない
// 実機での実行ができていない（アップデートの必要性がある）
// inputCommentVCで、コメント投稿後、なぜかtimeStampがnilになる　🟠
// svprogressの部分に注意　全部、1.0秒だけ遅らせて処理実行
// 二つのアカウントを作成して、アカウントを順番に削除しようとすると、別のアカウントにサインインできない　これはメールアドレスに空白（スペース）があるのが原因で、ログインできないから、スペースを削除する処理を書く必要がある
// コメント数の表示は、firebaseに書き込むのではなく、secondPostArray.countで表示させる（この方法は少しきついかも）　代替として、fieldValueでuidをコメント数分appendして、その配列のカウントをコメント数として、表示させる。🟠
// 投稿ボタン、コメント投稿ボタンを押下時に、textView.text = ""をさせるタイミングと❌ボタンで戻るをisEnabled = false　にする
// userNameLabelに表示する名前がダブってる displaynameだと思う

import RealmSwift
import SVProgressHUD
import UIKit

class TabBarController: UITabBarController {
    var tabBarController1: UITabBarController!
    let realm = try! Realm()
    var translationFolder: TranslationFolder!
    var array = [String]()
//    フォルダー作成時の文字数制限
    var maxCharactersLength: Int = 13

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarAppearence()
        self.giveTabBarControllerToEachOfViewControllers()
    }

    func setNavigationBarAppearence() {
        let appearance1 = UINavigationBarAppearance()
        appearance1.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance1
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance1

        self.selectedIndex = 2
        // タブアイコンの色
        tabBar.tintColor = UIColor.systemBlue
        // タブバーの背景色を設定
        let appearance2 = UITabBarAppearance()
        appearance2.backgroundColor = UIColor.systemGray6
        tabBar.standardAppearance = appearance2
        tabBar.scrollEdgeAppearance = appearance2
    }

    func giveTabBarControllerToEachOfViewControllers() {
        //        tabBarControllerへつながる各々のviewControlleクラスのtabBarControllerインスタンスを格納する変数tabBarController1にselfを指定
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

    func setBarButtonItem0() {
        navigationItem.title = "翻訳"
    }

    func setBarButtonItem1() {
        navigationItem.title = "フォルダー"
    }

    func setBarButtonItem2() {
        navigationItem.title = "履歴"
    }

    func setBarButtonItem3() {
        navigationItem.title = "学習記録"
    }

    func setBarButtonItem4() {
        navigationItem.title = "お気に入り"
    }

    // folderViewContoller画面を表示中にフォルダー作成した時に呼ばれる
    func tableViewReload() {
        //        「１」は　folderViewController
        if selectedIndex == 1 {
            let navigationController = viewControllers![1] as! UINavigationController
            let folderViewController = navigationController.viewControllers[0] as! FolderViewController
            folderViewController.tableView.reloadData()
        }
    }

//    右上のフォルダー作成アイコンタップ時
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
                let translationFolderArr = self.realm.objects(TranslationFolder.self)
                if translationFolderArr.isEmpty {
                } else {
                    for number in 0 ... translationFolderArr.count - 1 {
                        self.array.append(translationFolderArr[number].folderName)
                    }
                }

                //                同じフォルダー名や空文字の場合、作成できません。
                if self.array.contains(textField_text) != true, textField_text != "" {
                    self.translationFolder = TranslationFolder()

                    SVProgressHUD.show()

                    //            プライマリーキーであるidに値を設定（他のidと被らないように）
                    let allTranslationFolder = self.realm.objects(TranslationFolder.self)
                    if allTranslationFolder.count != 0 {
                        self.translationFolder.id = allTranslationFolder.max(ofProperty: "id")! + 1
                    }

                    //            （保存時の）現在の日付を取得
                    try! self.realm.write {
                        self.translationFolder.folderName = textField_text
                        self.translationFolder.date = Date()
                        self.realm.add(self.translationFolder)
                    }

                    SVProgressHUD.showSuccess(withStatus: "新規フォルダー\n\(textField_text)\nを追加しました。")
                }

                //                何も入力されていないなら
                if textField_text == "" {
                    SVProgressHUD.show()
                    SVProgressHUD.showError(withStatus: "フォルダー名を入力してください")
                    //                        同じフォルダー名があったら
                } else if self.array.contains(textField_text) {
                    SVProgressHUD.show()
                    SVProgressHUD.showError(withStatus: "同じフォルダー名は作成できません")
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { () in SVProgressHUD.dismiss() }
                self.tableViewReload()
            }
        }))
        present(alert, animated: true, completion: nil)
    }

//    タイムライン画面への遷移時
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "ToSecondTabBarController" {
            let secondTabBarController = segue.destination as! SecondTabBarController
//            プロフィール画面へsecondTabBarControllerインスタンスを渡す
            let navigationController = secondTabBarController.viewControllers![1] as! UINavigationController
            let profileViewController = navigationController.viewControllers[0] as! ProfileViewController
            profileViewController.secondTabBarController = secondTabBarController
//

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
        //        テキストフィールドのセレクションが変更される度に実行される　ここでテキストの最大文字数とスペースの規制を行う
        guard let textField_text = textField.text else { return }

        if textField_text.count > self.maxCharactersLength {
            textField.text = String(textField_text.prefix(self.maxCharactersLength))
        }
    }
}

// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
