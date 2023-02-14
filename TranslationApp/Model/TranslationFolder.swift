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
//    folder name
    @objc dynamic var folderName = ""

    @objc dynamic var date = Date()

    @objc dynamic var memo = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    var results = List<Translation>()
}

class Translation: Object {
//    sentences which you wanna translate
    @objc dynamic var inputData = ""
//    translated sentences that you entered
    @objc dynamic var resultData = ""

    @objc dynamic var id = 0
    // since there are 3 types of checkmark, use Int type instead of Bool type
    // change image icon by determing 1,2,3
    @objc dynamic var isChecked: Int = 0
    // display or non-display by tapping the cell
    @objc dynamic var isDisplayed: Bool = false
//    inputData + resultData
    @objc dynamic var inputAndResultData = ""
    
    @objc dynamic var secondMemo = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
