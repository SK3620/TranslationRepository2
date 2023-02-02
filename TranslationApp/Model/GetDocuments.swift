//
//  GetDocuments.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/02/01.
//

import Firebase
import SVProgressHUD
import UIKit

struct GetDocument {
    static func getDocumentsForTimeline(user: User, topic: String?, listener: ListenerRegistration?, completion: @escaping ([PostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データを取得中...")
        var postsRef: Query
        if let topic = topic {
            postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).order(by: "postedDate", descending: true).whereField("topic", arrayContains: topic)
        } else {
            postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).order(by: "postedDate", descending: true)
        }
        var listener = listener
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                return
            }
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                print("ドキュメントがありません")
                completion(postArray)
                return
            }
            querySnapshot!.documents.forEach { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                if postData.blockedBy.contains(user.uid) {
                    print("ブロックしたユーザーが含まれています")
                    return
                } else {
                    postArray.append(postData)
                    completion(postArray)
                }
            }
        }
    }

    //    also get other user's documents when you are on othersPostsHisotryViewController
    static func getMyDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping ([PostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: uid).order(by: "postedDate", descending: true)
        var listener = listener
        print(listener)
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.dismiss()
                return
            }
            // Create PostData based on the acquired document and make it into a postArray array.
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(postArray)
                return
            }
            postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            completion(postArray)
        }
    }

//    for postedCommentsHisotryVC and OthersPostedCommentsHistoryVC
    static func getMyCommentsDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping ([PostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: uid).order(by: "commentedDate", descending: true)
        var listener = listener
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.dismiss()
                return
            }
            // Create PostData based on the acquired document and make it into a postArray array.
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(postArray)
                return
            }
            postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            completion(postArray)
        }
    }

    static func getBookMarkedDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping ([PostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("bookMarks", arrayContains: uid).order(by: "postedDate", descending: true)
        var listener = listener
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.dismiss()
            }
            if let querySnapshot = querySnapshot {
                var postArray: [PostData] = []
                if querySnapshot.documents.isEmpty {
                    completion(postArray)
                    return
                }
                querySnapshot.documents.forEach { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    if postData.blockedBy.contains(uid) {
                        print("ブロックしたユーザーが含まれています")
                        return
                    } else {
                        postArray.append(postData)
                        completion(postArray)
                    }
                }
            }
        }
    }

//    for BookMarkCommentsSectionVC and CommentsHistoryVC, commentsSectionVC
    static func getCommentsDocuments(query: Query, listener: ListenerRegistration?, completion: @escaping ([SecondPostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        var listener = listener
        listener = query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            var secondPostArray: [SecondPostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(secondPostArray)
                return
            }
            querySnapshot!.documents.forEach { queryDocumentSnapshot in
                let secondPostData = SecondPostData(document: queryDocumentSnapshot)
                let user = Auth.auth().currentUser!
                if secondPostData.blockedBy.contains(user.uid) {
                    print("ブロックしたユーザーのドキュメントを除外m")
                } else {
                    secondPostArray.append(secondPostData)
                    completion(secondPostArray)
                }
            }
        }
    }

//    For BookMarkCommentsSectionVC and CommentsHistoryVC, OthersCommentsHistoryVC, CommentsSectionVC
    static func getSingleDocument(postData: PostData, listener: ListenerRegistration?, completion: @escaping (PostData) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
        var listener = listener
        listener = postsRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                SVProgressHUD.dismiss()
                return
            }
            if let documentSnapshot = documentSnapshot {
                let postData = PostData(document: documentSnapshot)
                completion(postData)
            }
        }
    }

//    For OthersCommentsHistoryVC
    static func getOthersCommentsDocuments(query: Query, listener: ListenerRegistration?, postData: PostData, completion: @escaping ([SecondPostData]) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        var listener = listener
        listener = query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            var secondPostArray: [SecondPostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(secondPostArray)
                return
            }
            querySnapshot!.documents.forEach { queryDocumentSnapshot in
                let secondPostData = SecondPostData(document: queryDocumentSnapshot)
                let user = Auth.auth().currentUser!
                if secondPostData.blockedBy.contains(user.uid), postData.uid != secondPostData.uid {
                    print("ブロックしたユーザーのドキュメントを除外")
                } else {
                    secondPostArray.append(secondPostData)
                    completion(secondPostArray)
                }
            }
        }
    }

//    in ChatListVC
    static func getChatListDocument(user: User, listener: ListenerRegistration?, completion: @escaping ([ChatList], [String]) -> Void) {
        let chatListRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).whereField("members", arrayContains: user.uid).order(by: "latestSentDate", descending: true)
        var listener = listener
        listener = chatListRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("ChatLists情報の取得に失敗しました。\(error)")
                return
            }
            print("ChatListsの情報の取得に成功しました")
            var chatListData: [ChatList] = []
            var documentIdArray: [String] = []
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty {
                    print("ChatListsのsnapshotsは空でした")
                    completion(chatListData, documentIdArray)
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    documentIdArray.append(queryDocumentSnapshot.documentID)
                    chatListData.append(ChatList(queryDocumentSnapshot: queryDocumentSnapshot))
                    completion(chatListData, documentIdArray)
                }
            }
        }
    }

//    in chatListVC
    // a process called when you got added as a friend by the other person (by a person who added you as thier friend)
    // when you are added, a person who added you as thier friend will automatically be displayed in the tableView
    static func observeIfYouAreAboutToBeAddedAsFriend(completion: @escaping (QueryDocumentSnapshot) -> Void) {
        let user = Auth.auth().currentUser!
        let chatRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).whereField("partnerUid", isEqualTo: user.uid)
        chatRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("友達追加した時の処理にて、getDocumenメソッドが失敗しました エラー内容：\(error)")
            }
            if let querySnapshot = querySnapshot {
                print("友達追加した時の処理にて、getDocumentメソッドが成功しました")
                if querySnapshot.isEmpty {
                    print("友達追加時の処理にて、getDocumentメソッドで取得したquerySnapshotは空でしたので、returnを実行します")
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    completion(queryDocumentSnapshot)
                }
            }
        }
    }
}
