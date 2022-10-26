//
//  PhraseWord.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/23.
//

import Foundation
import RealmSwift

class PhraseWord: Object{
//    翻訳したい文章
    @objc dynamic var inputData = ""
//    翻訳結果
    @objc dynamic var resultData = ""
    
    @objc dynamic var id = 0
    
    @objc dynamic var date = Date()
    
//    3種類の星マークのため、bool型ではなく、0,1,2で判定するInt型
    @objc dynamic var isChecked: Int = 0
//    文章タップで表示、非表示
    @objc dynamic var isDisplayed: Bool = false
    
    override static func primaryKey() -> String? {
        "id"
    }
}
