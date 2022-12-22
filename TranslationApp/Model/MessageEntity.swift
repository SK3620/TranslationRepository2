//
//  MessageEntity.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/16.
//

import Foundation
import MessageKit
import UIKit

struct MessageEntity: MessageType {
    var userName: String
    var messageId: String
    var sentDate: Date
    var sender: SenderType
    var kind: MessageKind

//    var sender: SenderType {
//        return isMe ? MessageSenderType.me : MessageSenderType.other
//        }

//    var kind: MessageKind {
//        return .attributedText(NSAttributedString(
//            string: self.message,
//            attributes: [.font: UIFont.systemFont(ofSize: 14.0),
//                         .foregroundColor: self.isMe
//                             ? UIColor.white
//                             : UIColor.label]
//        ))
//    }

    var stringSentDate: String {
        return self.convertDateToString(date: self.sentDate)
    }

    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d HH:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }

    static func createMyMessage(userName: String, text: String, sender: MessageSenderType, messageId: String, sentDate: Date) -> MessageEntity {
        return MessageEntity(userName: userName, messageId: messageId, sentDate: sentDate, sender: sender, kind: .attributedText(NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.white])))
    }

    static func createPartnerMessage(userName: String, text: String, sender: MessageSenderType, messageId: String, sentDate: Date) -> MessageEntity {
        return MessageEntity(userName: userName, messageId: messageId, sentDate: sentDate, sender: sender, kind: .attributedText(NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.label])))
    }
}
