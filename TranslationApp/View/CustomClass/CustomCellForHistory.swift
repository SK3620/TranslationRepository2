//
//  CustomCellTableViewCell.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import SVProgressHUD
import UIKit

class CustomCellForHistory: UITableViewCell {
    @IBOutlet private var label1: UILabel!
    @IBOutlet private var label2: UILabel!
    @IBOutlet private var label3: UILabel!

    @IBOutlet var copyButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureIcon()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setData(_ inputData2: String, _ resultData2: String, _ date2: String, _ indexPath_row: Int) {
        self.label1.text = inputData2
        self.label2.text = resultData2
        self.label3.text = "\(indexPath_row)" + "  " + date2
    }

    @IBAction func copyButtonAction(_: Any) {
        SVProgressHUD.showSuccess(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 1.5)
    }

    private func configureIcon() {
        let image1 = UIImage.SymbolConfiguration(pointSize: 19, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "doc.on.doc", withConfiguration: image1)
        self.copyButton.setImage(image2, for: .normal)
    }
}
