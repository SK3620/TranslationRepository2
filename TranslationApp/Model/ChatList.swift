//
//  ChatList.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/19.
//

import Firebase
import Foundation

class ChatList {
    var name: String?
    var latestMessage: String?
    var latestMessagedDate: String?
    var chatMembers: [String]?
    var chatMembersName: [String]?
    var documentId: String?

//    var profileImage:

    init(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.documentId = queryDocumentSnapshot.documentID

        let chatListDic = queryDocumentSnapshot.data()

        self.name = chatListDic["name"] as? String

        self.latestMessage = chatListDic["latestMessage"] as? String

        let timeStamp = chatListDic["latestSentDate"] as? Timestamp
        if let timeStamp = timeStamp {
            let latestMessagedDate = timeStamp.dateValue()
            let dateString = self.convertDateToString(date: latestMessagedDate)
            self.latestMessagedDate = dateString
        }

        self.chatMembers = chatListDic["members"] as? [String]

        self.chatMembersName = chatListDic["membersName"] as? [String]
    }

    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d HH:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
