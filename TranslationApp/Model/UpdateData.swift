//
//  UpdateData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/03.
//

import Firebase
import Foundation
import SVProgressHUD
import UIKit

struct UpdateData {
//    in ChatRoomVC
    static func updateLatestMessageAndLatestSentDate(text: String, chatListData: ChatList) {
        let chatListsRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).document(chatListData.documentId!)
        chatListsRef.updateData(["latestMessage": text]) { error in
            if let error = error {
                print(error)
            } else {
                print("latestMessageのupdate成功")
            }
            chatListsRef.updateData(["latestSentDate": FieldValue.serverTimestamp()]) { error in
                if let error = error {
                    print(error)
                } else {
                    print("latestSentDateのupdateに成功")
                }
            }
        }
    }
}
