//
//  Record.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/23.
//

import Foundation
import RealmSwift

class Record: Object {
//    folder name
    @objc dynamic var folderName = ""
//    sentence number or sentences which you learned
    @objc dynamic var number = ""
//    the number of times you reviewd
    @objc dynamic var times = ""
//    the next review date displayed in the cell
    @objc dynamic var nextReviewDate = ""
//    Display next review date in date order by .sorted(by: , acsending:)
    @objc dynamic var nextReviewDateForSorting: Int = 0
//    jsut a memo
    @objc dynamic var memo = ""
//    input date, recored date
    @objc dynamic var inputDate: String = ""

    @objc dynamic var date1 = ""
//    if it has already been reviewed or not
    @objc dynamic var isChecked: Bool = false

    @objc dynamic var id = 0

    override static func primaryKey() -> String? {
        return "id"
    }
}
