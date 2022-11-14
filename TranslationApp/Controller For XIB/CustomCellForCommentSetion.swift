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
    @IBOutlet var viewForSeparator: UIView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var bookMarkButton: UIButton!
    @IBOutlet var copyButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //        丸いimageView
        self.imageView1.layer.cornerRadius = self.imageView1.frame.height / 2
        //        画像にデフォルト設定
        self.imageView1.layer.borderColor = UIColor.systemGray4.cgColor
        self.imageView1.layer.borderWidth = 2
        self.setButtonImage(button: self.copyButton, systemName: "doc.on.doc")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setSecondPostData(secondPostData: SecondPostData) {
//        プロフィール画像設定
        let imageRef = Storage.storage().reference(forURL: "gs://translationapp-72dd8.appspot.com").child(FireBaseRelatedPath.imagePath).child("\(secondPostData.uid!)" + ".jpg")
        self.imageView1.sd_setImage(with: imageRef)

        self.userNameLabel.text = secondPostData.userName!

        // 日時の表示
        self.postedDateLabel.text = ""
        if let date = secondPostData.commentedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.M.d HH:mm"
            let dateString = formatter.string(from: date)
            self.postedDateLabel.text = dateString
        }

        self.commentLabel.text = secondPostData.comment!

        // いいね数の表示
        let likeNumber = secondPostData.likes.count
        self.heartLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if secondPostData.isLiked {
            self.setButtonImage(button: self.heartButton, systemName: "heart.fill")
            self.heartButton.tintColor = UIColor.systemRed
        } else {
            self.setButtonImage(button: self.heartButton, systemName: "heart")
            self.heartButton.tintColor = UIColor.darkGray
        }

//        bookMarkの表示
        if secondPostData.isBookMarked {
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
