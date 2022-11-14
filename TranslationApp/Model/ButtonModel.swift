//
//  File.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Foundation
import UIKit

// モデルクラスの使い方練習
class ButtonModel: NSObject {
    var buttonIsTapped: Bool = false

    init(button: UIButton, postViewController: PostViewController) {
        if button.backgroundColor == .white {
            //            ボタンが押されていると認識している状態
            self.buttonIsTapped = true
            button.backgroundColor = .systemCyan
            button.tintColor = .white
            button.layer.borderWidth = 1.5
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.systemCyan.cgColor
            postViewController.array.append(button.titleLabel!.text!)

        } else {
            //            ボタンが押されてないと認識している状態
            button.backgroundColor = .white
            button.tintColor = .systemGray2
            button.layer.borderWidth = 1.5
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.systemGray2.cgColor
            postViewController.array.removeAll(where: { $0 == button.titleLabel!.text! })
        }
    }
}
