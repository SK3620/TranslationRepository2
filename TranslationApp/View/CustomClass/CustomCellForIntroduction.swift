//
//  CustomCellForProfile.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/28.
//

import UIKit

class CustomCellForIntroduction: UITableViewCell {
    @IBOutlet var introductionLabel: UILabel!
    @IBOutlet var academicHistoryLable: UILabel!
    @IBOutlet var hobbyLable: UILabel!
    @IBOutlet var visitedCountryLable: UILabel!
    @IBOutlet var wannaVisistCountryLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var birthdayLabel: UILabel!
    @IBOutlet var etcLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.introductionLabel.text = "ーーー"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setProfileData(profileData: [String: Any]) {
        self.introductionLabel.text = profileData["introduction"] as? String
        self.academicHistoryLable.text = profileData["academicHistory"] as? String
        self.hobbyLable.text = profileData["hobby"] as? String
        self.visitedCountryLable.text = profileData["visitedCountry"] as? String
        self.wannaVisistCountryLabel.text = profileData["wannaVisitCountry"] as? String
        self.placeLabel.text = profileData["whereYouLive"] as? String
        self.birthdayLabel.text = profileData["birthday"] as? String
        self.etcLabel.text = profileData["etc"] as? String
    }
}
