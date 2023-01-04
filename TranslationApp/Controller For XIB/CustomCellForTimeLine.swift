//
//  CustomCellForTimeLine.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import FirebaseStorageUI
import UIKit

class CustomCellForTimeLine: UITableViewCell {
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var contentOfPostLabel: UILabel!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var bubbleLabel: UILabel!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var bubbleButton: UIButton!
    @IBOutlet var bookMarkButton: UIButton!
    @IBOutlet var postedDateLabel: UILabel!

    @IBOutlet var imageView1: UIImageView!

    @IBOutlet var commentButton: UIButton!
    @IBOutlet var buttonOnImageView1: UIButton!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var cellEditButton: UIButton!

    // the number of likes displayed in the profile
    private var likeNumber: Int = 0

    var listener: ListenerRegistration?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setButtonImage(button: self.bubbleButton, systemName: "bubble.left")
        self.setButtonImage(button: self.bookMarkButton, systemName: "bookMark")
        self.setButtonImage(button: self.copyButton, systemName: "doc.on.doc")
        self.setButtonImage(button: self.cellEditButton, systemName: "ellipsis")
        self.bubbleButton.tintColor = .darkGray
        //        丸いimageView
        self.imageView1.layer.cornerRadius = self.imageView1.frame.height / 2
        //        画像にデフォルト設定
        self.imageView1.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView1.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setPostData(_ postData: PostData) {
//        if postData.profileImageUrl == nil {
//            self.imageView1.image = UIImage(systemName: "person")
//            print("２回実行？person")
//        } else {
//            let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(postData.profileImageUrl!)")
//            imageRef.downloadURL { url, error in
//                if let error = error {
//                    print("URLの取得失敗\(error)")
//                }
//                if let url = url {
//                    print("URLの取得成功: \(url)")
//                    self.imageView1.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
//                    print("2回実行だー")
//                }
//            }
//        }

        if let imageUrl = postData.profileImageUrl {
            self.imageView1.sd_setImage(with: imageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
        } else {
            self.imageView1.image = UIImage(systemName: "person")
        }

//            display user name
        self.userNameLabel.text = postData.userName

//       display content of post
        self.contentOfPostLabel.text = postData.contentOfPost
        if let comment = postData.comment {
            self.contentOfPostLabel.text = comment
        }

        // display the date
        self.postedDateLabel.text = ""
        if let postedDate = postData.postedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.M.d HH:mm"
            let dateString = formatter.string(from: postedDate)
            self.postedDateLabel.text = dateString
        }
        if let commentedDate = postData.commentedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.M.d HH:mm"
            let dateString = formatter.string(from: commentedDate)
            self.postedDateLabel.text = dateString
        }

        // the number of comments
        if let numberOfComments = postData.numberOfComments {
            self.bubbleLabel.text = numberOfComments
        } else {
            self.bubbleLabel.text = "0"
        }

        // display the number of likes
        let likeNumber = postData.likes.count
        self.heartLabel.text = "\(likeNumber)"
        self.likeNumber = likeNumber

        if postData.isLiked {
            self.setButtonImage(button: self.heartButton, systemName: "heart.fill")
            self.heartButton.tintColor = UIColor.systemRed
        } else {
            self.setButtonImage(button: self.heartButton, systemName: "heart")
            self.heartButton.tintColor = UIColor.darkGray
        }

//       display bookMark
        if postData.isBookMarked {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark.fill")
            self.bookMarkButton.tintColor = UIColor.systemGreen
        } else {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark")
            self.bookMarkButton.tintColor = UIColor.darkGray
        }
    }

    func setButtonImage(button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular, scale: .small)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
    }
}
