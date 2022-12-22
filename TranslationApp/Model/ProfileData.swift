//
//  ProfileData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/22.
//

import Firebase
import Foundation

class ProfileData {
    var userName: String?

    init(documentSnapshot: DocumentSnapshot) {
        let dic = documentSnapshot.data()
        self.userName = dic!["userName"] as? String
    }
}
