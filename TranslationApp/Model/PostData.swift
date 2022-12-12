//
//  PostData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import UIKit

class PostData: NSObject {
    var documentId: String
    var userName: String?
//    投稿内容
    var contentOfPost: String?
//    コメント
    var comment: String?
    var postedDate: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var bookMarks: [String] = []
    var isBookMarked: Bool = false
    var numberOfComments: String?
    var uid: String?

//    var timeStamp: Timestamp?
//    var commentedDate: Date?
    var stringCommentedDate: String?
    var documentIdForPosts: String?
    var commentedDate: Date?

    init(document: QueryDocumentSnapshot) {
        print("postDataクラスが実行された")
        self.documentId = document.documentID

        let postDic = document.data()

        self.userName = postDic["userName"] as? String

        self.contentOfPost = postDic["contentOfPost"] as? String
        self.comment = postDic["comment"] as? String

        let timestamp = postDic["postedDate"] as? Timestamp
        self.postedDate = timestamp?.dateValue()

        if let likes = postDic["likes"] as? [String] {
//            「いいね」したユーザのuidを保持する
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }

        if let bookMarks = postDic["bookMarks"] as? [String] {
//            「bookMark」したユーザのuidを保持する
            self.bookMarks = bookMarks
        }
        if let myid = Auth.auth().currentUser?.uid {
            // bookMarksの配列の中にmyidが含まれているかチェックすることで、自分がbookMarkを押しているかを判断
            if self.bookMarks.firstIndex(of: myid) != nil {
                // myidがあれば、bookMarkを押していると認識する。
                self.isBookMarked = true
            }
        }

//        コメント数表示
        self.numberOfComments = postDic["numberOfComments"] as? String

//        投稿者のuid
        self.uid = postDic["uid"] as? String

//        self.timeStamp = postDic["commentedDate"] as? Timestamp
//        self.commentedDate = self.timeStamp?.dateValue()

        self.stringCommentedDate = postDic["stringCommentedDate"] as? String
        self.documentIdForPosts = postDic["documentIdForPosts"] as? String

        let date = postDic["commentedDate"] as? Timestamp
        self.commentedDate = date?.dateValue()
    }

//    CommentSectionViewController画面で単一のドキュメントを監視した時
    init(document: DocumentSnapshot) {
        print("postDataクラスが実行された")
        self.documentId = document.documentID

        let postDic = document.data()!

        self.userName = postDic["userName"] as? String

        self.contentOfPost = postDic["contentOfPost"] as? String

        let timestamp = postDic["postedDate"] as? Timestamp
        self.postedDate = timestamp?.dateValue()

        if let likes = postDic["likes"] as? [String] {
//            「いいね」したユーザのuidを保持する
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }

        if let bookMarks = postDic["bookMarks"] as? [String] {
//            「bookMark」したユーザのuidを保持する
            self.bookMarks = bookMarks
        }
        if let myid = Auth.auth().currentUser?.uid {
            // bookMarksの配列の中にmyidが含まれているかチェックすることで、自分がbookMarkを押しているかを判断
            if self.bookMarks.firstIndex(of: myid) != nil {
                // myidがあれば、bookMarkを押していると認識する。
                self.isBookMarked = true
            }
        }
        //        コメント数表示
        self.numberOfComments = postDic["numberOfComments"] as? String

        //    投稿者のuid
        self.uid = postDic["uid"] as? String
    }
}
