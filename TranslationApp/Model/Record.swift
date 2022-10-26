//
//  Record.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/23.
//

import Foundation
import RealmSwift

class Record: Object{
//    フォルダー名
    @objc dynamic var folderName = ""
//    学習した文章番号・内容
    @objc dynamic var number = ""
//    復習回数
    @objc dynamic var times = ""
//    次回復習日
    @objc dynamic var nextReviewDate = ""
//    次回復習日を日付順
    @objc dynamic var nextReviewDateForSorting: Int = 0
//    メモ
    @objc dynamic var memo = ""
//    入力（記録）された日付
    @objc dynamic var inputDate: String = ""

    @objc dynamic var date1 = ""
    
    @objc dynamic var date2 = Date()
//    復習完了マーク
    @objc dynamic var isChecked: Bool = false
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
