//
//  CustomCellForHistory2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/02.
//

import UIKit

class CustomCellForHistory2ViewController: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var displayButton1: UIButton!
    @IBOutlet weak var displayButton2: UIButton!
    @IBOutlet weak var cellEditButton: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ inputData: String, _ indexPath_row: Int){
        self.label1.text = inputData
        
        if indexPath_row % 2 == 0 {
            self.numberLabel.backgroundColor = UIColor.systemGray6
        } else {
            self.numberLabel.backgroundColor = UIColor.systemGray4
        }
        
        self.numberLabel.text = "\(indexPath_row + 100)"
    }
    
    func setData2(_ resultData: String){
        self.label2.text = resultData
    }
    
}
