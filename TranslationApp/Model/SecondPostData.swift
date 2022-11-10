//
//  SecondPostData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/04.
//

import Firebase
import UIKit

class SecondPostData {
    var documentId: String?
//    コメントしたuidを格納
    var peopleCommented: [String] = []
//    コメント内容
    var comment: String?
//    コメントした日
    var commentedDate: Date?
//    コメントした人の名前
    var userName: String?
//    コメントしたuidのプロフィール画像
    var profileImage: StorageReference?
//    コメント数
    var numberOfComments: Int?
    var likes: [String] = []
    var isLiked: Bool = false
    var bookMarks: [String] = []
    var isBookMarked: Bool = false
    var uid: String?

    init(document: QueryDocumentSnapshot) {
        print("secondPostDataクラスが実行された")

        self.documentId = document.documentID

        let postDic = document.data()

        self.userName = postDic["userName"] as? String

        let commentedDate = postDic["commentedDate"] as? Timestamp
        self.commentedDate = commentedDate?.dateValue()

        self.comment = postDic["comment"] as? String

        if let peopleCommented = postDic["uid"] as? [String] {
            self.peopleCommented = peopleCommented
        }

        self.numberOfComments = self.peopleCommented.count

        let imageRef: StorageReference = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(postDic["uid"] as! String)" + ".jpg")
        self.profileImage = imageRef

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
//        投稿者のuid
        self.uid = postDic["uid"] as? String
    }
}
