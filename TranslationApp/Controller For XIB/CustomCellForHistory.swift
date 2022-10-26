//
//  CustomCellTableViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import UIKit

class CustomCellForHistory: UITableViewCell {
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var copyButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.changeIcon()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(_ inputData2: String, _ resultData2: String, _ date2: String, _ indexPath_row: Int) {
        self.label1.text = inputData2
        self.label2.text = resultData2
        self.label3.text = "\(indexPath_row)" + "  " + date2
    }

    @IBAction func copyButtonAction(_: Any) {
        let image1 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "checkmark", withConfiguration: image1)
        self.copyButton.setImage(image2, for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.changeIcon)
    }

    func changeIcon() {
        let image1 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "doc.on.doc", withConfiguration: image1)
        self.copyButton.setImage(image2, for: .normal)
        self.copyButton.setTitle("copy", for: .normal)
    }
}
