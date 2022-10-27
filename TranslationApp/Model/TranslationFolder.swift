//
//  RealmDataBase.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/30.
//

import Foundation
import RealmSwift

class TranslationFolder: Object {
    @objc dynamic var id = 0
//    フォルダー名
    @objc dynamic var folderName = ""

    @objc dynamic var date = Date()

    @objc dynamic var memo = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    var results = List<Translation>()
}

class Translation: Object {
//    翻訳したい文章
    @objc dynamic var inputData = ""
//    翻訳結果
    @objc dynamic var resultData = ""

    @objc dynamic var id = 0
//    ブックマーク（星マーク）ボタンを押すごとに3種類の星マークがあるため、0,1,2のInt型で判定
    @objc dynamic var isChecked: Int = 0
    //   　文章タップで表示、非表示
    @objc dynamic var isDisplayed: Bool = false
//    inputData + resultData
    @objc dynamic var inputAndResultData = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
