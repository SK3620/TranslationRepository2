//
//  CustomCellForHistory2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/02.
//

import UIKit

protocol LongPressDetectionDelegate: AnyObject {
    func longPressDetection(_ indexPath_row: Int, _ cell: CustomCellForStudy)
}

class CustomCellForStudy: UITableViewCell {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var checkMarkButton: UIButton!
    @IBOutlet var displayButton1: UIButton!
    @IBOutlet var displayButton2: UIButton!
    @IBOutlet var cellEditButton: UIButton!

    var delegate: LongPressDetectionDelegate!
    var indexPath_row: Int!
    var cell: CustomCellForStudy!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("実行されたよー")
        let reconizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressButton(_:)))

        self.displayButton2.addGestureRecognizer(reconizer)
        self.displayButton1.addGestureRecognizer(reconizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func longPressButton(_ sender: UILongPressGestureRecognizer) {
        print("タップ")
        if sender.state == UIGestureRecognizer.State.began {
            print("長押し開始")
            self.delegate.longPressDetection(self.indexPath_row, self.cell)
        } else if sender.state == UIGestureRecognizer.State.ended {
            print("長押し終了")
        }
    }

    func setData(_ inputData: String, _ indexPath_row: Int) {
        self.label1.text = inputData

        self.numberLabel.backgroundColor = .systemGray6

        self.numberLabel.text = "\(indexPath_row + 1)"
    }

    func setData2(_ resultData: String) {
        self.label2.text = resultData
    }
}
