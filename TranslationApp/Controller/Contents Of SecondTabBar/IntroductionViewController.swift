//
//  IntroductionViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/30.
//

import Firebase
import Parchment
import SVProgressHUD
import UIKit

class IntroductionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    var profileData: [String: Any] = [:]
    var secondTabBarController: SecondTabBarController!
    var pagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pagingViewController.select(index: 1)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        let nib = UINib(nibName: "CustomCellForIntroduction", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        self.pagingViewController.select(index: 0)

        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setProfileData()
    }

    func setProfileData() {
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user.uid)'sProfileDocument").getDocument { snap, error in
                if let error = error {
                    print("取得失敗\(error)")
                }
                //                Retrieves all fields in the document as an `NSDictionary`. Returns `nil` if the document doesn't exist.
                //                Declaration
                //                func data() -> [String : Any]?
                guard let profileData = snap?.data() else { return }
                self.profileData = profileData
                self.tableView.reloadData()
            }
        } else {
            self.tableView.reloadData()
        }
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
            print("postDataじっこう")
        }
        return cell
    }
}
