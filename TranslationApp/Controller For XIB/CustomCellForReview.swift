//
//  ReviewCustomCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/30.
//

import UIKit

class CustomCellForReview: UITableViewCell {
    @IBOutlet private var reviewDate: UILabel!
    @IBOutlet private var folderName: UILabel!
    @IBOutlet private var content: UILabel!
    @IBOutlet private var memo: UILabel!
    @IBOutlet private var times: UILabel!
    @IBOutlet private var inputDate: UILabel!

    @IBOutlet var checkMarkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setData(_ reviewDate: String, _ folderName: String, _ content: String, _ memo: String, _ times: String, _ inputDate: String) {
        if reviewDate != "" {
            self.reviewDate.text = reviewDate
        } else {
            self.reviewDate.text = " "
        }

        if folderName != "" {
            self.folderName.text = folderName
        } else {
            self.folderName.text = " "
        }

        if content != "" {
            self.content.text = content
        } else {
            self.content.text = " "
        }

        if memo != "" {
            self.memo.text = memo
        } else {
            self.memo.text = " "
        }

        if times != "" {
            self.times.text = times
        } else {
            self.times.text = " "
        }

        if inputDate != "" {
            self.inputDate.text = inputDate
        } else {
            self.inputDate.text = " "
        }
    }
}
