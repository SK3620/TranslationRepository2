//
//  SecondPostData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/04.
//

import Firebase
import UIKit

class SecondPostData {
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

    init(document: QueryDocumentSnapshot) {
        print("secondPostDataクラスが実行された")

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
    }
}
