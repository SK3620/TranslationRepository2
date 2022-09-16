//
//  CustomCellTableViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ inputData2: String, _ resultData2: String, _ date2: String, _ indexPath_row: Int){
        
        self.label1.text = inputData2
        self.label2.text = resultData2
        self.label3.text = "\(indexPath_row)" + "  " + date2
    }
    
    
    
}
