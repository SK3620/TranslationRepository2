//
//  CustomCell2.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/15.
//

import RealmSwift
import UIKit

protocol ToEditViewContollerDelegate: AnyObject {
    func ToEditViewContoller()
}

class CustomCellForRecord: UITableViewCell {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    @IBOutlet var label5: UILabel!
    @IBOutlet var label6: UILabel!

    @IBOutlet var checkMarkButton: UIButton!

//    weak var delegate: ToEditViewContollerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    @IBAction func editButtonAction(_ sender: Any) {
//
//        self.delegate?.ToEditViewContoller()
//    }

    func setData(_ recordArrFilter: Record) {
        if recordArrFilter.folderName != "" {
            self.label1.text = recordArrFilter.folderName
        } else {
            self.label1.text = " "
        }

        if recordArrFilter.number != "" {
            self.label2.text = recordArrFilter.number
        } else {
            self.label2.text = " "
        }

        if recordArrFilter.times != "" {
            self.label3.text = recordArrFilter.times
        } else {
            self.label3.text = " "
        }

        if recordArrFilter.nextReviewDate != "" {
            self.label4.text = recordArrFilter.nextReviewDate
        } else {
            self.label4.text = " "
        }

        if recordArrFilter.memo != "" {
            self.label5.text = recordArrFilter.memo
        } else {
            self.label5.text = " "
        }
    }
}
