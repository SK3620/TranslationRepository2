//
//  ChatList.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/19.
//

import Firebase
import Foundation

class ChatList {
    var latestMessage: String?
    var latestMessagedDate: String?
    var chatMembers: [String]?
    var chatMembersName: [String]?
    var documentId: String?
    var partnerProfileImageUrl: URL?
    var myProfileImageUrl: URL?

    init(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.documentId = queryDocumentSnapshot.documentID

        let chatListDic = queryDocumentSnapshot.data()

        self.latestMessage = chatListDic["latestMessage"] as? String

        let timeStamp = chatListDic["latestSentDate"] as? Timestamp
        if let timeStamp = timeStamp {
            let latestMessagedDate = timeStamp.dateValue()
            let dateString = self.convertDateToString(date: latestMessagedDate)
            self.latestMessagedDate = dateString
        }

        self.chatMembers = chatListDic["members"] as? [String]

        self.chatMembersName = chatListDic["membersName"] as? [String]

        var myUid = ""
        var partnerUid = ""
        let user = Auth.auth().currentUser!
        if self.chatMembers?.first == user.uid {
            myUid = (self.chatMembers?.first)!
            partnerUid = self.chatMembers![1]
        } else {
            myUid = self.chatMembers![1]
            partnerUid = self.chatMembers!.first!
        }

        if let imageUrlString = chatListDic[partnerUid] as? String {
            if imageUrlString != "nil" {
                self.partnerProfileImageUrl = URL(string: imageUrlString)
            } else {
                self.partnerProfileImageUrl = nil
            }
        } else {
            self.partnerProfileImageUrl = nil
        }

        if let imageUrlString = chatListDic[myUid] as? String {
            if imageUrlString != "nil" {
                self.myProfileImageUrl = URL(string: imageUrlString)
            } else {
                self.myProfileImageUrl = nil
            }
        } else {
            self.myProfileImageUrl = nil
        }
    }

    private func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d HH:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
