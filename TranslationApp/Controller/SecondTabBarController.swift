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

        // タブアイコンの色
        tabBar.tintColor = UIColor.systemBlue
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.systemGray5
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
