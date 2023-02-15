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
    static func getDocumentsForTimeline(user: User, topic: String?, listener: ListenerRegistration?, completion: @escaping (Result<[PostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データを取得中...")
        var postsRef: Query
        if let topic = topic {
            postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).order(by: "postedDate", descending: true).whereField("topic", arrayContains: topic)
        } else {
            postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).order(by: "postedDate", descending: true)
        }
        var listener = listener
        print(listener as Any)
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                print("ドキュメントがありません")
                completion(.success(postArray))
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
                    completion(.success(postArray))
                }
            }
        }
    }

    //    also get other user's documents when you are on othersPostsHisotryViewController
    static func getMyDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping (Result<[PostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: uid).order(by: "postedDate", descending: true)
        var listener = listener
        print(listener as Any)
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            // Create PostData based on the acquired document and make it into a postArray array.
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(.success(postArray))
                return
            }
            postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            completion(.success(postArray))
        }
    }

//    for postedCommentsHisotryVC and OthersPostedCommentsHistoryVC
    static func getMyCommentsDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping (Result<[PostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: uid).order(by: "commentedDate", descending: true)
        var listener = listener
        print(listener as Any)
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            // Create PostData based on the acquired document and make it into a postArray array.
            var postArray: [PostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(.success(postArray))
                return
            }
            postArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let postData = PostData(document: document)
                return postData
            }
            completion(.success(postArray))
        }
    }

    static func getBookMarkedDocuments(uid: String, listener: ListenerRegistration?, completion: @escaping (Result<[PostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中...")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("bookMarks", arrayContains: uid).order(by: "postedDate", descending: true)
        var listener = listener
        print(listener as Any)
        listener = postsRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            if let querySnapshot = querySnapshot {
                var postArray: [PostData] = []
                if querySnapshot.documents.isEmpty {
                    completion(.success(postArray))
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
                        completion(.success(postArray))
                    }
                }
            }
        }
    }

//    for BookMarkCommentsSectionVC and CommentsHistoryVC, commentsSectionVC
    static func getCommentsDocuments(query: Query, listener: ListenerRegistration?, completion: @escaping (Result<[SecondPostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        var listener = listener
        print(listener as Any)
        listener = query.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            var secondPostArray: [SecondPostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(.success(secondPostArray))
                return
            }
            querySnapshot!.documents.forEach { queryDocumentSnapshot in
                let secondPostData = SecondPostData(document: queryDocumentSnapshot)
                let user = Auth.auth().currentUser!
                if secondPostData.blockedBy.contains(user.uid) {
                    print("ブロックしたユーザーのドキュメントを除外m")
                } else {
                    secondPostArray.append(secondPostData)
                    completion(.success(secondPostArray))
                }
            }
        }
    }

//    For BookMarkCommentsSectionVC and CommentsHistoryVC, OthersCommentsHistoryVC, CommentsSectionVC
    static func getSingleDocument(postData: PostData, listener: ListenerRegistration?, completion: @escaping (Result<PostData, Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(postData.documentId)
        var listener = listener
        print(listener as Any)
        listener = postsRef.addSnapshotListener { documentSnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            if let documentSnapshot = documentSnapshot {
                let postData = PostData(document: documentSnapshot)
                completion(.success(postData))
            }
        }
    }

//    For OthersCommentsHistoryVC
    static func getOthersCommentsDocuments(query: Query, listener: ListenerRegistration?, postData: PostData, completion: @escaping (Result<[SecondPostData], Error>) -> Void) {
        SVProgressHUD.show(withStatus: "データ取得中")
        var listener = listener
        print(listener as Any)
        listener = query.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            var secondPostArray: [SecondPostData] = []
            if querySnapshot!.documents.isEmpty {
                completion(.success(secondPostArray))
                return
            }
            querySnapshot!.documents.forEach { queryDocumentSnapshot in
                let secondPostData = SecondPostData(document: queryDocumentSnapshot)
                let user = Auth.auth().currentUser!
                if secondPostData.blockedBy.contains(user.uid), postData.uid != secondPostData.uid {
                    print("ブロックしたユーザーのドキュメントを除外")
                } else {
                    secondPostArray.append(secondPostData)
                    completion(.success(secondPostArray))
                }
            }
        }
    }

//    in ChatListVC
    static func getChatListDocument(user: User, listener: ListenerRegistration?, completion: @escaping ([ChatList], [String]) -> Void) {
        let chatListRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).whereField("members", arrayContains: user.uid).order(by: "latestSentDate", descending: true)
        var listener = listener
        print(listener as Any)
        listener = chatListRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                print("データの取得に失敗しました\(error.localizedDescription)")
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
    static func observeIfYouAreAboutToBeAddedAsFriend(completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> Void) {
        let user = Auth.auth().currentUser!
        let chatRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).whereField("partnerUid", isEqualTo: user.uid)
        chatRef.getDocuments { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                print("友達追加した時の処理にて、getDocumenメソッドが失敗しました エラー内容：\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                completion(.failure(error))
                return
            }
            if let querySnapshot = querySnapshot {
                print("友達追加した時の処理にて、getDocumentメソッドが成功しました")
                if querySnapshot.documents.isEmpty {
                    print("友達追加時の処理にて、getDocumentメソッドで取得したquerySnapshotは空でしたので、returnを実行します")
                    return
                }
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    completion(.success(queryDocumentSnapshot))
                }
            }
        }
    }

//    in ChatRoomVC
    static func getMessagesDocument(chatListData: ChatList, listener: ListenerRegistration?, completion: @escaping ([MessageEntity], [ChatRoom]) -> Void) {
        let messagesRef = Firestore.firestore().collection(FireBaseRelatedPath.chatListsPath).document(chatListData.documentId!).collection("messages").order(by: "sentDate", descending: false)
        var listener = listener
        print(listener as Any)
        listener = messagesRef.addSnapshotListener { querySnapshot, error in
            guard Auth.auth().currentUser != nil else {
                return
            }
            if let error = error {
                print("リスナーでmessagesコレクション内のドキュメント取得失敗:エラー内容\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "データの取得に失敗しました")
                return
            }
            if let querySnapshot = querySnapshot {
                let messageList: [MessageEntity] = []
                var chatRoomArr: [ChatRoom] = []
                var countedQuerySnaopshot: Int = querySnapshot.documents.count
                if querySnapshot.documents.isEmpty {
                    return
                }
                print("リスナーでmessagesコレクション内のドキュメント取得成功")
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    chatRoomArr.append(ChatRoom(document: queryDocumentSnapshot))
                    countedQuerySnaopshot = countedQuerySnaopshot - 1
                    if countedQuerySnaopshot == 0 {
                        completion(messageList, chatRoomArr)
                    }
                }
            }
        }
    }
}
