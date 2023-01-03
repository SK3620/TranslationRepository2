//
//  PostData.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import FirebaseStorage
import UIKit

class PostData: NSObject {
    var documentId: String
    var userName: String?
    var contentOfPost: String?
    var comment: String?
    var postedDate: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var bookMarks: [String] = []
    var isBookMarked: Bool = false
    // displayed next to the bubble icon
    var numberOfComments: String?
    var uid: String?
    // string type commented type which has already been converted from Date into String
    var stringCommentedDate: String?
    var documentIdForPosts: String?
    var commentedDate: Date?
    var profileImageUrl: String?

    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID

        let postDic = document.data()

        self.userName = postDic["userName"] as? String

        self.contentOfPost = postDic["contentOfPost"] as? String
        self.comment = postDic["comment"] as? String

        let timestamp = postDic["postedDate"] as? Timestamp
        self.postedDate = timestamp?.dateValue()

        if let likes = postDic["likes"] as? [String] {
            // Keep uid of "liked" user
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            // Check if myid is included in the likes array to determine if I am a like
            if self.likes.firstIndex(of: myid) != nil {
                // If there is a myid, we recognize it as a like.
                self.isLiked = true
            }
        }

        if let bookMarks = postDic["bookMarks"] as? [String] {
            // Keep uid of "bookMarked" user
            self.bookMarks = bookMarks
        }
        if let myid = Auth.auth().currentUser?.uid {
            // Determine if you've pushed bookMark by checking if myid is included in the bookMarks array
            if self.bookMarks.firstIndex(of: myid) != nil {
                // If there is a myid, it recognizes that the bookMark is being pressed.
                self.isBookMarked = true
            }
        }

//        number of comments
        self.numberOfComments = postDic["numberOfComments"] as? String

//        uid of the person who posted
        self.uid = postDic["uid"] as? String

        self.stringCommentedDate = postDic["stringCommentedDate"] as? String

        // Document ID of the submission for the comment
        self.documentIdForPosts = postDic["documentIdForPosts"] as? String

        let date = postDic["commentedDate"] as? Timestamp
        self.commentedDate = date?.dateValue()

        // string type "nil" or "user.uid.jpg" is going to be stored
        let isProfileImageExisted = postDic["isProfileImageExisted"] as? String
        if isProfileImageExisted != "nil" {
            self.profileImageUrl = isProfileImageExisted
        } else {
            self.profileImageUrl = nil
        }
    }

    // When a single document is retrieved on the CommentSectionViewController screen
    init(document: DocumentSnapshot) {
        self.documentId = document.documentID

        let postDic = document.data()!

        self.userName = postDic["userName"] as? String

        self.contentOfPost = postDic["contentOfPost"] as? String

        let timestamp = postDic["postedDate"] as? Timestamp
        self.postedDate = timestamp?.dateValue()

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
        self.numberOfComments = postDic["numberOfComments"] as? String

        self.uid = postDic["uid"] as? String

        // string type "nil" or "user.uid.jpg" is going to be stored
        let isProfileImageExisted = postDic["isProfileImageExisted"] as? String
        if isProfileImageExisted != "nil" {
            self.profileImageUrl = isProfileImageExisted
        } else {
            self.profileImageUrl = nil
        }
    }
}
