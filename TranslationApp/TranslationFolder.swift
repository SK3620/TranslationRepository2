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
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


