//
//  CustomPhraseWordViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/28.
//

import UIKit

protocol CheckCellDelegate: AnyObject {
    func reloadCell(index: IndexPath)
}

class CustomCellForPhraseWord: UITableViewCell {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!

    @IBOutlet var checkMarkButton: UIButton!
    @IBOutlet var displayButton1: UIButton!
    @IBOutlet var displayButton2: UIButton!

    @IBOutlet var numberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.label1.numberOfLines = 0
        self.label2.numberOfLines = 0
    }

    @IBAction func checkMarkButtonAction(_: Any) {}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData1(_ inputData: String, _ indexPath_row: Int) {
        self.label1.text = inputData
        if indexPath_row % 2 == 0 {
            self.numberLabel.backgroundColor = UIColor.systemGray6
        } else {
            self.numberLabel.backgroundColor = UIColor.systemGray4
        }
        self.numberLabel.text = "\(indexPath_row + 1)"
    }

    func setData2(_ resultData: String) {
        self.label2.text = resultData
    }

    @IBAction func button(_: Any) {
        print("displayButton0")
    }
}
