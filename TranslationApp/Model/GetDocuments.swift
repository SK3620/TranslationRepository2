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
}
