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
    // Stores the uid of the commenter
    var peopleCommented: [String] = []
    var comment: String?
    var commentedDate: Date?
    // Commenter's name
    var userName: String?
//    profile image of commenter's uid
    var numberOfComments: Int?
    var likes: [String] = []
    var isLiked: Bool = false
    var bookMarks: [String] = []
    var isBookMarked: Bool = false
    var uid: String?
    var stringCommentedDate: String?
    var profileImageUrl: URL?
    var blockedBy: [String] = []

    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID

        let postDic = document.data()

        self.userName = postDic["userName"] as? String

        let timeStamp = postDic["commentedDate"] as? Timestamp
        self.commentedDate = timeStamp?.dateValue()

        self.comment = postDic["comment"] as? String

        if let peopleCommented = postDic["uid"] as? [String] {
            self.peopleCommented = peopleCommented
        }

        self.numberOfComments = self.peopleCommented.count

        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            if self.likes.firstIndex(of: myid) != nil {
                self.isLiked = true
            }
        }

        if let bookMarks = postDic["bookMarks"] as? [String] {
            self.bookMarks = bookMarks
        }
        if let myid = Auth.auth().currentUser?.uid {
            if self.bookMarks.firstIndex(of: myid) != nil {
                self.isBookMarked = true
            }
        }
        self.uid = postDic["uid"] as? String

        self.stringCommentedDate = postDic["stringCommentedDate"] as? String

        // string type "nil" or "user.uid.jpg" is going to be stored
        if let isProfileImageExisted = postDic["isProfileImageExisted"] as? String {
            if isProfileImageExisted != "nil" {
                self.profileImageUrl = URL(string: isProfileImageExisted)
            } else {
                self.profileImageUrl = nil
            }
        }

        if let blockedBy = postDic["blockedBy"] as? [String] {
            self.blockedBy = blockedBy
        }
    }
}
