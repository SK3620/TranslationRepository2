//
//  CustomPhraseWordViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/28.
//

import UIKit

protocol CheckCellDelegate {
    func reloadCell(index: IndexPath)
}

class CustomPhraseWordViewCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var displayButton: UIButton!
    @IBOutlet weak var displayButton0: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label1.numberOfLines = 0
        label2.numberOfLines = 0
    }
    
    @IBAction func checkMarkButtonAction(_ sender: Any) {
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData1(_ inputData: String, _ indexPath_row: Int){
        self.label1.text = "\(indexPath_row + 1): " + inputData
//        self.label2.text = resultData
    }
    
    func setData2(_ resultData: String){
        self.label2.text = resultData
        
    }
    
}
