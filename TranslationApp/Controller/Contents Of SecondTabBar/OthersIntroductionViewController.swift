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

class OthersIntroductionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var profileData: [String: Any] = [:]
    var postData: PostData!

    var secondPagingViewController: PagingViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.secondPagingViewController.select(index: 1)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForIntroduction", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        self.secondPagingViewController.select(index: 0)
        print("確認\(self.postData.uid)")
        self.getProfileDataDocument()
    }

    func getProfileDataDocument() {
        print("実行だ")
        Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(self.postData.uid!)'sProfileDocument").getDocument(completion: { queryDocument, error in
            if let error = error {
                print("ドキュメント取得失敗\(error)")
            }
            if let queryDocument = queryDocument?.data() {
                print("取得成功\(queryDocument)")
                self.profileData = queryDocument
                self.tableView.reloadData()
            }
        })
        // Do any additional setup after loading the view.
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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
