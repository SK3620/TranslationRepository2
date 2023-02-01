//
//  BlockData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/01/25.
//

import Firebase
import UIKit

class BlockData: NSObject {
    var documentId: String
    var userName: String?
    var blockedBy: String?
    var blockedUser: String?
    var blockedDate: Date?
    var profileImageUrl: URL?

    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID

        let blockDic = document.data()

        self.userName = blockDic["userName"] as? String

        self.blockedBy = blockDic["blockedBy"] as? String

        self.blockedUser = blockDic["blockedUser"] as? String

        let timeStamp = blockDic["blockedDate"] as? Timestamp
        self.blockedDate = timeStamp?.dateValue()

        if let profileImageUrlString = blockDic["profileImageUrlString"] as? String {
            if profileImageUrlString != "nil" {
                self.profileImageUrl = URL(string: profileImageUrlString)
                print("urlあり")
            } else {
                self.profileImageUrl = nil
                print("urlなし")
            }
        }
    }
}
