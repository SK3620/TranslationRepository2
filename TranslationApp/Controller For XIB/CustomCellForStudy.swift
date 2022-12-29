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
    @IBOutlet private var numberLabel: UILabel!

    @IBOutlet var checkMarkButton: UIButton!
    @IBOutlet var displayButton1: UIButton!
    @IBOutlet var displayButton2: UIButton!
    @IBOutlet var cellEditButton: UIButton!

    var delegate: LongPressDetectionDelegate!
    var indexPath_row: Int!
    var customCellForStudy: CustomCellForStudy!

    override func awakeFromNib() {
        super.awakeFromNib()
        let reconizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressButton(_:)))
        self.displayButton2.addGestureRecognizer(reconizer)
        self.displayButton1.addGestureRecognizer(reconizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc func longPressButton(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            self.delegate.longPressDetection(self.indexPath_row, self.customCellForStudy)
        } else if sender.state == UIGestureRecognizer.State.ended {
            print("longPress終了")
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
