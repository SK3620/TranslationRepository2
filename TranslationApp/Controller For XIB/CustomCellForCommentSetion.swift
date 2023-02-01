//
//  CustomCellForCommentSetion.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/04.
//

import Firebase
import FirebaseStorageUI
import UIKit

class CustomCellForCommentSetion: UITableViewCell {
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var postedDateLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!

    @IBOutlet private var viewForSeparator: UIView!

    @IBOutlet var heartButton: UIButton!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var bookMarkButton: UIButton!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var buttonOnImageView1: UIButton!
    @IBOutlet var cellEditButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        //        circle imageView
        self.imageView1.layer.cornerRadius = self.imageView1.frame.height / 2
        //        default setting for the image
        self.imageView1.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView1.layer.borderWidth = 2
        self.setButtonImage(button: self.copyButton, systemName: "doc.on.doc")
        self.setButtonImage(button: self.cellEditButton, systemName: "ellipsis")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setSecondPostData(secondPostData: SecondPostData) {
//        if secondPostData.profileImageUrl == nil {
//            self.imageView1.image = UIImage(systemName: "person")
//        } else {
//            let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(secondPostData.profileImageUrl!)")
//            imageRef.downloadURL { url, error in
//                if let error = error {
//                    print("URLの取得失敗\(error)")
//                }
//                if let url = url {
//                    print("URLの取得成功: \(url)")
//                    self.imageView1.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
//                }
//            }
//        }

        if let imageUrl = secondPostData.profileImageUrl {
            self.imageView1.sd_setImage(with: imageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
        } else {
            self.imageView1.image = UIImage(systemName: "person")
        }

        self.userNameLabel.text = secondPostData.userName!

        // display of the date
        self.postedDateLabel.text = ""
        if let date = secondPostData.commentedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.M.d HH:mm"
            let dateString = formatter.string(from: date)
            self.postedDateLabel.text = dateString
        }

        if self.postedDateLabel.text == "" || self.postedDateLabel.text == nil {
            self.postedDateLabel.text = secondPostData.stringCommentedDate
        }

        self.commentLabel.text = secondPostData.comment!

        // the number of likes
        let likeNumber = secondPostData.likes.count
        self.heartLabel.text = "\(likeNumber)"

        // display like button
        if secondPostData.isLiked {
            self.setButtonImage(button: self.heartButton, systemName: "heart.fill")
            self.heartButton.tintColor = UIColor.systemRed
        } else {
            self.setButtonImage(button: self.heartButton, systemName: "heart")
            self.heartButton.tintColor = UIColor.darkGray
        }

//       display bookMark
        if secondPostData.isBookMarked {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark.fill")
            self.bookMarkButton.tintColor = UIColor.systemGreen
        } else {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark")
            self.bookMarkButton.tintColor = UIColor.darkGray
        }
    }

    private func setButtonImage(button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
    }
}
