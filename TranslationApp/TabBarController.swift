//
//  TabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import UIKit

class TabBarController: UITabBarController {
    
    var tabBarController1: UITabBarController!

    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.selectedIndex = 2
        // タブアイコンの色
        self.tabBar.tintColor = UIColor.systemBlue
            // タブバーの背景色を設定
            let appearance = UITabBarAppearance()
        appearance.backgroundColor =  UIColor.systemGray4
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        
    
        
        let navigationController0 = viewControllers![0] as! UINavigationController
        let rirekiViewController = navigationController0.viewControllers[0] as! RirekiViewController
        rirekiViewController.tabBarController1 = self
        
        let navigationController1 = viewControllers![1] as! UINavigationController
        let historyViewController = navigationController1.viewControllers[0] as! HistoryViewController
        historyViewController.tabBarController1 = self
        
        let navigationController2 = viewControllers![2] as! UINavigationController
        let translateViewController = navigationController2.viewControllers[0] as! TranslateViewController
        translateViewController.tabBarController1 = self
        
        let navigationController3 = viewControllers![3] as! UINavigationController
        let phraseViewController = navigationController3.viewControllers[0] as! PhraseViewController
        phraseViewController.tabBarController1 = self
        
        let navigationController4 = viewControllers![4] as! UINavigationController
        let recordViewController = navigationController4.viewControllers[0] as! RecordViewController
        recordViewController.tabBarController1 = self
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("遷移しました")
        
        if segue.identifier == "ToCreateViewContoller" {
        let createFolderController = segue.destination as! CreateFolderViewController
        createFolderController.tabBarController2 = self
        }
        
    }
    
    func tableViewReload(){
        if selectedIndex == 1 {
            let navigationController = viewControllers![1] as! UINavigationController
            let historyViewController = navigationController.viewControllers[0] as! HistoryViewController
            historyViewController.tableView.reloadData()
            print("確認50")
        }
    }
    
    func setBarButtonItem0(){
            navigationItem.title = "翻訳"
    }
    func setBarButtonItem1(){
            navigationItem.title = "フォルダー"
    }
    func setBarButtonItem2(){
            navigationItem.title = "履歴"
    }
    func setBarButtonItem3(){
            navigationItem.title = "学習記録"
    }
    func setBarButtonItem4(){
            navigationItem.title = "単語・フレーズ"
    }
}



// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
    


