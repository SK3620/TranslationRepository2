//
//  CustomCellForEditProfile.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/31.
//

import Firebase
import UIKit

class CustomCellForEditProfile: UITableViewCell, UITextFieldDelegate {
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var workTextField: UITextField!
    @IBOutlet var introductionTextView: UITextView!
    @IBOutlet var academicHistoryTextView: UITextView!
    @IBOutlet var hobbyTextView: UITextView!
    @IBOutlet var visitedCountryTextView: UITextView!
    @IBOutlet var wannaVisitCountryTextView: UITextView!
    @IBOutlet var whereYouLiveTextField: UITextField!
    @IBOutlet var birthdayTextField: UITextField!
    @IBOutlet var etcTextView: UITextView!

    private var maxPasswordLength: Int = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userNameTextField.delegate = self

        let textFieldArr: [UITextField]! = [userNameTextField, genderTextField, ageTextField, workTextField, birthdayTextField, whereYouLiveTextField]
        let textViewArr: [UITextView]! = [introductionTextView, academicHistoryTextView, hobbyTextView, visitedCountryTextView, wannaVisitCountryTextView, etcTextView]
        self.setTextFieldAndViewDesign(textFieldArr: textFieldArr, textViewArr: textViewArr)
    }

    internal func textFieldDidChangeSelection(_: UITextField) {
        guard let userName = userNameTextField.text else { return }

        if userName.count > self.maxPasswordLength {
            self.userNameTextField.text = String(userName.prefix(self.maxPasswordLength))
        }
    }

    private func setTextFieldAndViewDesign(textFieldArr: [UITextField], textViewArr: [UITextView]) {
        textFieldArr.forEach {
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 6
        }
        textViewArr.forEach {
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 6
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setProfileData(profileData: [String: Any]) {
        self.userNameTextField.text = Auth.auth().currentUser?.displayName!
        self.genderTextField.text = profileData["gender"] as? String
        self.ageTextField.text = profileData["age"] as? String
        self.workTextField.text = profileData["work"] as? String
        self.introductionTextView.text = profileData["introduction"] as? String
        self.academicHistoryTextView.text = profileData["academicHistory"] as? String
        self.hobbyTextView.text = profileData["hobby"] as? String
        self.visitedCountryTextView.text = profileData["visitedCountry"] as? String
        self.wannaVisitCountryTextView.text = profileData["wannaVisitCountry"] as? String
        self.whereYouLiveTextField.text = profileData["whereYouLive"] as? String
        self.birthdayTextField.text = profileData["birthday"] as? String
        self.etcTextView.text = profileData["etc"] as? String
    }
}
