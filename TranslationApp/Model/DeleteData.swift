//
//  DeleteData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/02.
//

import Firebase
import Foundation
import SVProgressHUD
import UIKit

struct DeleteData {
    //    in PostsHistoryVC
    static func deletePostsData(postData: PostData) {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")

        SVProgressHUD.showSuccess(withStatus: "削除完了")
        SVProgressHUD.dismiss(withDelay: 1.0) {
            dispatchGroup.enter()
            dispatchQueue.async {
                Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId).delete { error in
                    if let error = error {
                        print("投稿データの削除失敗\(error)")
                    } else {
                        print("投稿データの削除成功")
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: postData.documentId)

                commentsRef.getDocuments { querySnapshot, error in
                    if let error = error {
                        print("コメントの取得失敗/またはコメントがありません\(error)")
                    }
                    if let querySnapshot = querySnapshot {
                        print("コメントを取得しました\(querySnapshot)")
                        querySnapshot.documents.forEach {
                            $0.reference.delete(completion: { error in
                                if let error = error {
                                    print("コメント削除失敗\(error)")
                                } else {
                                    print("コメント削除成功")
                                }
                            })
                        }
                    }
                }
            }
        }
    }

    //    in PostedCommentsHistoryVC
    static func deleteCommentsData(postData: PostData) {
        let dispatchGruop = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue")
        var updatedNumberOfComments = "0"

        // delete comment data
        dispatchGruop.enter()
        dispatchQueue.async {
            Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(postData.documentId).delete { error in
                if let error = error {
                    print("コメントデータの削除失敗\(error)")
                } else {
                    print("コメントデータの削除成功")
                    let commentsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("documentIdForPosts", isEqualTo: postData.documentIdForPosts!)
                    commentsRef.getDocuments { querySnapshot, error in
                        if let error = error {
                            print("エラーでした：エラー内容\(error)")
                        }
                        if let querySnapshot = querySnapshot {
                            updatedNumberOfComments = String(querySnapshot.documents.count)
                            dispatchGruop.leave()
                        }
                    }
                }
            }

            // update the number of comments
            dispatchGruop.notify(queue: .main, execute: {
                let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentIdForPosts!)
                let updatedPostDic = [
                    "numberOfComments": updatedNumberOfComments,
                ]
                postsRef.setData(updatedPostDic, merge: true) { error in
                    if let error = error {
                        print("updatedNumberOfCommentsの更新失敗\(error)")
                        return
                    } else {
                        print("updatedNumberOfCommentsの更新成功")
                    }
                }
            })
        }
    }

//    in ChatListVC
    static func deleteMessages(indexPath: IndexPath, documentIdArray: [String], completion: @escaping (Error?) -> Void) {
        SVProgressHUD.show()
        let messageRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).document(documentIdArray[indexPath.row]).collection("messages")
        messageRef.getDocuments { querySnapshot, error in
            if let error = error {
                completion(error)
            }
            if let querySnapshot = querySnapshot {
                if querySnapshot.isEmpty {
                    completion(nil)
                    return
                }
                var countedQuerySnapshot: Int = querySnapshot.documents.count
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    queryDocumentSnapshot.reference.delete { error in
                        if let error = error {
                            completion(error)
                        } else {
                            countedQuerySnapshot -= 1
                            if countedQuerySnapshot == 0 {
                                print("messagesコレクション内の全てのドキュメントの削除に成功しました")
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }

    static func deleteDocumentInChatListsCollection(documentIdArray: [String], indexPath: IndexPath, completion: @escaping () -> Void) {
        let chatListsRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).document(documentIdArray[indexPath.row])
        chatListsRef.delete { error in
            if let error = error {
                print("エラー\(error)")
                SVProgressHUD.showError(withStatus: "削除に失敗しました")
            } else {
                print("chatListsコレクション内のドキュメントの削除に成功しました")
                SVProgressHUD.showSuccess(withStatus: "削除完了")
                SVProgressHUD.dismiss(withDelay: 1.5) {
                    completion()
                }
            }
        }
    }
}
