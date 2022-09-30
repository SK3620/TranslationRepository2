//
//  RealmDataBase.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/30.
//

import Foundation
import RealmSwift

class TranslationFolder: Object{
    
    @objc dynamic var id = 0
    
    @objc dynamic var folderName = ""
    
    @objc dynamic var date = Date()
    
    @objc dynamic var memo = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var results = List<Translation>()
}

class Translation: Object {
    
    @objc dynamic var inputData = ""
    
    @objc dynamic var resultData = ""
    
    @objc dynamic var id = 0
    
    @objc dynamic var isChecked: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Histroy: Object{
    
    @objc dynamic var inputData2 = ""
    
    @objc dynamic var resultData2 = ""
    
    @objc dynamic var date2 = Date()
    
    @objc dynamic var id = 0
    
    override
    static func primaryKey() -> String? {
        return "id"
    }
}

class Record: Object{
    
    @objc dynamic var folderName = ""
    
    @objc dynamic var number = ""
    
    @objc dynamic var times = ""
    
    @objc dynamic var nextReviewDate = ""
    
    @objc dynamic var memo = ""
    
    @objc dynamic var date3 = ""
    
    @objc dynamic var id = 0
    
    @objc dynamic var date4 = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Record2: Object{
    
    @objc dynamic var inputData3 = ""
    
    @objc dynamic var resultData3 = ""
    
    @objc dynamic var id = 0
    
    @objc dynamic var date5 = Date()
    
    @objc dynamic var isChecked: Int = 0
    
    @objc dynamic var isDisplayed: Int = 0
    
    override static func primaryKey() -> String? {
        "id"
    }
}

class Memo: Object {
    
    @objc dynamic var memo2 = ""
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String? {
        "id"
    }
}


