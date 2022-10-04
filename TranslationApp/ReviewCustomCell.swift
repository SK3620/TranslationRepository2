//
//  ReviewCustomCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/30.
//

import UIKit

class ReviewCustomCell: UITableViewCell {
    
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var times: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ reviewDate: String, _ folderName: String, _ content: String, _ memo: String, _ times: String){
        self.reviewDate.text = reviewDate
        self.folderName.text = folderName
        self.content.text = content
        self.memo.text = memo
        self.times.text = times
    }
    
}
