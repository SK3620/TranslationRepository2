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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

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

    func setSecondPostData(secondPostData: SecondPostData) {
//        プロフィール画像設定
        self.imageView1.sd_setImage(with: secondPostData.profileImage!)

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
    }
}
