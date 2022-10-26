//
//  FirstMemo.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/24.
//

import Foundation
import RealmSwift

//QuickMemoViewController（簡単メモ）画面用のModelクラス
class FirstMemo: Object {
    
    @objc dynamic var memo = ""
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String? {
        "id"
    }
}
