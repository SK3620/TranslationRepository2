//
//  Speak.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/24.
//

import Foundation
import RealmSwift

// used in studyViewController
class Speak: Object {
    //    Play audio of the input text (false: do not play, true: play)
    @objc dynamic var playInputData: Bool = false
    //    Play audio of the input text (false: do not play, true: play)
    @objc dynamic var playResultData: Bool = true

    @objc dynamic var id = 0

    override static func primaryKey() -> String? {
        "id"
    }
}
