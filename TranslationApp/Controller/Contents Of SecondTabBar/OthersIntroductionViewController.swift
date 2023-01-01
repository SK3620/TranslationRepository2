//
//  OthersIntroductionViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/07.
//

import Firebase
import Parchment
import SVProgressHUD
import UIKit

// function described here is almost the same as the one in IntroductionViewController
class OthersIntroductionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    var profileData: [String: Any] = [:]

    var postData: PostData!

    var secondPagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.secondPagingViewController.select(index: 1)

        self.settingsForTableView()
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForIntroduction", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.secondPagingViewController.select(index: 0)
        self.getProfileDataDocument()
    }

    private func getProfileDataDocument() {
        SVProgressHUD.show(withStatus: "データ取得中...")
        Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(self.postData.uid!)'sProfileDocument").getDocument(completion: { queryDocument, error in
            if let error = error {
                print("ドキュメント取得失敗\(error)")
            }
            if let queryDocument = queryDocument?.data() {
                print("取得成功\(queryDocument)")
                self.profileData = queryDocument
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
        })
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellForIntroduction

        let Arr = [cell.introductionLabel, cell.etcLabel, cell.birthdayLabel, cell.placeLabel, cell.wannaVisistCountryLabel, cell.hobbyLable, cell.visitedCountryLable, cell.academicHistoryLable]
        Arr.forEach {
            $0?.text = "ー"
        }

        if Auth.auth().currentUser != nil {
            cell.setProfileData(profileData: self.profileData)
        }
        return cell
    }
}
