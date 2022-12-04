//
//  SecondTabBarController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import UIKit

class SecondTabBarController: UITabBarController {
    var rightBarButtonItems: [UIBarButtonItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
        // Do any additional setup after loading the view.
    }

    func setNavigationBar() {
        // タブアイコンの色
        tabBar.tintColor = UIColor.systemBlue
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.systemGray5
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
