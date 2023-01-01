//
//  MessageSenderType.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/12/16.
//

import Foundation
import MessageKit
import UIKit

struct MessageSenderType: SenderType {
    var senderId: String
    var displayName: String

    static func mymessageSenderType(mySenderId: String, myDisplayName: String) -> MessageSenderType {
        return MessageSenderType(senderId: mySenderId, displayName: myDisplayName)
    }

    static func partnerMessageSenderType(partnerSenderId: String, partnerDisplayName: String) -> MessageSenderType {
        return MessageSenderType(senderId: partnerSenderId, displayName: partnerDisplayName)
    }
}
