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
    }

    func setNavigationBar() {
        // settings for backGroundColor
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
