//
//  RealmDataBase.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/30.
//

import Foundation
import RealmSwift

class RealmDataBase: Object{
    
    @objc dynamic var id = 0
    
    @objc dynamic var folderName = ""
    
    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
