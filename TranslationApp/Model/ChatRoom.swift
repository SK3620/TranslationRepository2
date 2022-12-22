//
//  ChatRoom.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/20.
//

import Firebase
import Foundation

class ChatRoom {
    var senderUid: String?
    var message: String?
    var senderName: String?
    var sentDate: Date?
    var documentId: String?

    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID

        let messageDic = document.data()

        self.senderUid = messageDic["senderUid"] as? String

        self.message = messageDic["message"] as? String

        self.senderName = messageDic["senderName"] as? String

        let timeStamp = messageDic["sentDate"] as? Timestamp
        self.sentDate = timeStamp?.dateValue()

        //        それはサーバーで時刻の値が決まるまで、値が空で返ってきてしまう。

        if self.sentDate == nil {
            let timeStamp = document.get("sentDate", serverTimestampBehavior: .estimate) as? Timestamp
            self.sentDate = timeStamp?.dateValue()
        }

        print(self.message)
        print(self.senderUid)
        print(self.senderName)
        print(self.sentDate)
    }
}
