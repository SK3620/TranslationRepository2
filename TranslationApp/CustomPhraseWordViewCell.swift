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
    @IBOutlet weak var numberLabel: UILabel!
    
    
    
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
        self.label1.text = inputData
        if indexPath_row % 2 == 0 {
            self.numberLabel.backgroundColor = UIColor.systemGray6
        } else {
            self.numberLabel.backgroundColor = UIColor.systemGray4
        }
        self.numberLabel.text = "\(indexPath_row + 1)"
    }
    
    func setData2(_ resultData: String){
        self.label2.text = resultData
        
    }
    
    @IBAction func button(_ sender: Any) {
        print("displayButton0")
    }
    
}
