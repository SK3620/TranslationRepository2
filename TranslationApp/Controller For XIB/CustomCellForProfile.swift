//
//  CustomCellForProfile.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/28.
//

import UIKit

class CustomCellForProfile: UITableViewCell {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
