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
//    in PostVC
    static func determinationOfIsProfileImageExisted(completion: @escaping (String) -> Void) {
        let user = Auth.auth().currentUser!
        let profileImagesRef = Firestore.firestore().collection(FireBaseRelatedPath.imagePathForDB).document("\(user.uid)'sProfileImage")
        profileImagesRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("エラー　\(error)")
            }
            var valueForIsProfileImageExisted: String
            if let documentSnapshot = documentSnapshot, let imagesDic = documentSnapshot.data() {
                let isProfileImageExisted = imagesDic["isProfileImageExisted"] as? String
                if isProfileImageExisted != "nil" {
                    valueForIsProfileImageExisted = isProfileImageExisted!
                } else {
                    valueForIsProfileImageExisted = "nil"
                }
            } else {
                valueForIsProfileImageExisted = "nil"
            }
            completion(valueForIsProfileImageExisted)
        }
    }

//    in PostVC
    static func writePostData(blockedBy: [String], text: String, valueForIsProfileImageExisted: String, array: [String], completion: @escaping () -> Void) {
        let user = Auth.auth().currentUser!
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document()
        let postDic = [
            "contentOfPost": text,
            "postedDate": FieldValue.serverTimestamp(),
            "userName": user.displayName!,
            "uid": user.uid,
            "numberOfComments": "0",
            "isProfileImageExisted": valueForIsProfileImageExisted,
            "blockedBy": blockedBy,
        ] as [String: Any]
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        SVProgressHUD.dismiss(withDelay: 1.5) {
            postRef.setData(postDic) { error in
                if let error = error {
                    print("エラーでした\(error)")
                    return
                }
                let value = FieldValue.arrayUnion(array)
                postRef.updateData(["topic": value]) { error in
                    if let error = error {
                        print(error)
                    } else {
                        completion()
                    }
                }
            }
        }
    }

//    in InputCommentVC
    static func writeCommentData(postData: PostData, blockedBy: [String], text: String, today: String, valueForIsProfileImageExisted: String, completion: @escaping () -> Void) {
        if let user = Auth.auth().currentUser {
            let commentsDic = [
                "uid": user.uid,
                "userName": user.displayName!,
                "comment": text,
                "commentedDate": FieldValue.serverTimestamp(),
                "stringCommentedDate": today,
                "documentIdForPosts": postData.documentId,
                "isProfileImageExisted": valueForIsProfileImageExisted,
                "blockedBy": blockedBy,
            ] as [String: Any]
            let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document()
            commentsRef.setData(commentsDic, merge: false) { error in
                if let error = error {
                    print("”comments”にへの書き込み失敗\(error)")
                } else {
                    print("”comments”への書き込み成功")
                    completion()
                }
            }
        }
    }

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
