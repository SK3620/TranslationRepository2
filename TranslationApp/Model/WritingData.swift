//
//  WritingData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/02.
//

import Firebase
import Foundation
import SVProgressHUD
import UIKit

struct WritingData {
//    in ChatRoomVC
    static func writeMessageData(text: String, chatListData: ChatList) {
        let user = Auth.auth().currentUser
        let messageDic = [
            "senderUid": user!.uid,
            "message": text,
            "senderName": user!.displayName!,
            "sentDate": FieldValue.serverTimestamp(),
        ] as [String: Any]
        Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).document(chatListData.documentId!).collection("messages").document().setData(messageDic) { error in
            if let error = error {
                print("messagesコレクション内への書き込みに失敗しました エラー内容：\(error)")
            } else {
                print("メッセージ送信とmessagesコレクション内への書き込みに成功しました")
                UpdateData.updateLatestMessageAndLatestSentDate(text: text, chatListData: chatListData)
            }
        }
    }
}
