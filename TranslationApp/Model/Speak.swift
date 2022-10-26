//
//  Speak.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/24.
//

import Foundation
import RealmSwift

//StudyViewControllerで使用する。
class Speak: Object {
//　入力した文章を音声再生 (falseで再生しない、trueで再生）
    @objc dynamic var playInputData: Bool = false
//　翻訳結果を音声再生
    @objc dynamic var playResultData: Bool = true
    
    @objc dynamic var id = 0

    override static func primaryKey() -> String? {
        "id"
    }
}
