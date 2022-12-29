//
//  PhraseWord.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/23.
//

import Foundation
import RealmSwift

class PhraseWord: Object {
    @objc dynamic var inputData = ""

    @objc dynamic var resultData = ""

    @objc dynamic var id = 0

    @objc dynamic var date = Date()

    // since there are 3 types of checkmark, use Int type instead of Bool type
    // change image icon by determing 1,2,3
    @objc dynamic var isChecked: Int = 0
//    display or non-display sentences by tapping
    @objc dynamic var isDisplayed: Bool = false

    override static func primaryKey() -> String? {
        "id"
    }
}
