//
//  History.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/23.
//

import Foundation
import RealmSwift

class Histroy: Object {
    @objc dynamic var inputData = ""

    @objc dynamic var resultData = ""

    @objc dynamic var date = Date()

    @objc dynamic var id = 0

    @objc dynamic var inputAndResultData = ""

    override
    static func primaryKey() -> String? {
        return "id"
    }
}
