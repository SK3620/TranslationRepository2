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
    @IBOutlet weak var inputDate: UILabel!
    
    @IBOutlet weak var checkMarkButton: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ reviewDate: String, _ folderName: String, _ content: String, _ memo: String, _ times: String, _ inputDate: String){
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
