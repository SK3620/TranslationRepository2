//
//  TabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/08.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController {
    
    var tabBarController1: UITabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タブアイコンの色
        self.tabBar.tintColor = UIColor.systemBlue
            // タブバーの背景色を設定
            let appearance = UITabBarAppearance()
        appearance.backgroundColor =  UIColor.systemGray4
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("遷移しました")
        
        let createFolderController = segue.destination as! CreateFolderViewController
        createFolderController.tabBarController2 = self
        
    }
    
    func tableViewReload(){
        if selectedIndex == 1 {
            let navigationController = viewControllers![1] as! UINavigationController
            let historyViewController = navigationController.viewControllers[0] as! HistoryViewController
            historyViewController.tableView.reloadData()
        }
    }
    
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    

}
