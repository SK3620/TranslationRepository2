//
//  CollectionViewCellForBlockList.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/01/24.
//

import FirebaseStorageUI
import UIKit

class CollectionViewCellForBlockList: UICollectionViewCell {
    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var userNameLabel: UILabel!

    @IBOutlet var buttonOnProfileImageView: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.settingsForProfileImageView()
    }

    internal func settingsForProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.borderWidth = 2
    }

    internal func setProfileImageViewAndUserNameLabel(blockData: BlockData) {
        if let imageUrl = blockData.profileImageUrl {
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: SDWebImageOptions.refreshCached, context: nil)
            print("画像あり")
        } else {
            self.profileImageView.image = UIImage(systemName: "person")
            print("画像なし")
        }

        self.userNameLabel.text = blockData.userName!
    }
}
