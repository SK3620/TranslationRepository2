//
//  CustomCellForTimeLine.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setButtonImage(button: self.bubbleButton, systemName: "bubble.left")
        self.setButtonImage(button: self.bookMarkButton, systemName: "bookMark")
        self.bubbleButton.tintColor = .darkGray
        //        丸いimageView
        self.imageView1.layer.cornerRadius = self.imageView1.frame.height / 2
        //        画像にデフォルト設定
        self.imageView1.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView1.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
//            プロフィール写真設定
        let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(postData.uid!)" + ".jpg")
        self.imageView1.sd_setImage(with: imageRef)

//            ユーザー名表示
        self.userNameLabel.text = postData.userName
        // 投稿内容表示
        self.contentOfPostLabel.text = postData.contentOfPost
        if let comment = postData.comment {
            self.contentOfPostLabel.text = comment
        }

        // 日時の表示
        self.postedDateLabel.text = ""
        if let date = postData.postedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.M.d HH:mm"
            let dateString = formatter.string(from: date)
            self.postedDateLabel.text = dateString
        }

//        コメント数の表示
        if let numberOfComments = postData.numberOfComments {
            self.bubbleLabel.text = numberOfComments
        } else {
            self.bubbleLabel.text = "0"
        }

        // いいね数の表示
        let likeNumber = postData.likes.count
        self.heartLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            self.setButtonImage(button: self.heartButton, systemName: "heart.fill")
            self.heartButton.tintColor = UIColor.systemRed
        } else {
            self.setButtonImage(button: self.heartButton, systemName: "heart")
            self.heartButton.tintColor = UIColor.darkGray
        }

//        bookMarkの表示
        if postData.isBookMarked {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark.fill")
            self.bookMarkButton.tintColor = UIColor.systemGreen
        } else {
            self.setButtonImage(button: self.bookMarkButton, systemName: "bookmark")
            self.bookMarkButton.tintColor = UIColor.darkGray
        }
    }

    func setButtonImage(button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
    }
}
