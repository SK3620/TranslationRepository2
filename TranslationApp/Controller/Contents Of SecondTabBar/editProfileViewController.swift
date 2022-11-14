//
//  editProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/28.
//

import Firebase
import SVProgressHUD
import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var textFieldArr: [UITextField]! = []
    var textViewArr: [UITextView]! = []
    var textFieldAndView_textArr: [String] = []

    var postArrayForDocId: [String] = []

    var profileViewController: ProfileViewController!
    var secondTabBarController: SecondTabBarController!

    var profileData: [String: Any] = [:]

    var userNameText: String?
    var genderText: String?
    var ageText: String?
    var workText: String?
    var introductionText: String?
    var academicHistoryText: String?
    var hobbyText: String?
    var visitedCountryText: String?
    var wannaVisitCountryText: String?
    var whereYouLiveText: String?
    var birthdaytext: String?
    var etcText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray4
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        self.title = "編集"
        //        順番が大事
        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.profileViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        let rightBarButtonItem = UIBarButtonItem(title: "保存する", style: .plain, target: self, action: nil)
        self.profileViewController.navigationController?.navigationItem.rightBarButtonItems = [rightBarButtonItem]

        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForEditProfile", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")

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
                print("データ確認\(self.profileData)")
            }
        }
    }

    override func viewWillDisappear(_: Bool) {
        super.viewWillDisappear(true)
        self.secondTabBarController.navigationController?.setNavigationBarHidden(false, animated: false)
        self.profileViewController.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCellForEditProfile

        self.textFieldArr = [cell.userNameTextField, cell.genderTextField, cell.ageTextField, cell.whereYouLiveTextField, cell.birthdayTextField]
        self.textViewArr = [cell.workTextView, cell.introductionTextView, cell.academicHistoryTextView, cell.hobbyTextView, cell.visitedCountryTextView, cell.wannaVisitCountryTextView, cell.etcTextView]
        self.setDoneToolBar(textFieldArr: self.textFieldArr, textViewArr: self.textViewArr)

        cell.setProfileData(profileData: self.profileData)
        print("実行")
        print(self.profileData)

        return cell
    }

    func setDoneToolBar(textFieldArr: [UITextField]!, textViewArr: [UITextView]!) {
        // 決定バーの生成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        // インプットビュー設定
        textFieldArr.forEach {
            $0.inputAccessoryView = toolbar
        }

        textViewArr.forEach {
            $0.inputAccessoryView = toolbar
        }
    }

    @objc func done() {
        self.textFieldArr.forEach {
            $0.endEditing(true)
        }
        self.textViewArr.forEach {
            $0.endEditing(true)
        }
    }

    @IBAction func rightBarButtonItem(_: Any) {
        print("バーボタンアイテム")

        SVProgressHUD.show()

        self.userNameText = self.textFieldArr[0].text
        if self.userNameText == "" || self.userNameText == "ー" {
            SVProgressHUD.showError(withStatus: "名前を入力してください")
            return
        }

        self.genderText = self.textFieldArr[1].text
        self.ageText = self.textFieldArr[2].text
        self.workText = self.textViewArr[0].text
        self.introductionText = self.textViewArr[1].text
        self.academicHistoryText = self.textViewArr[2].text
        self.hobbyText = self.textViewArr[3].text
        self.visitedCountryText = self.textViewArr[4].text
        self.wannaVisitCountryText = self.textViewArr[5].text
        self.whereYouLiveText = self.textFieldArr[3].text
        self.birthdaytext = self.textFieldArr[4].text
        self.etcText = self.textViewArr[6].text

        //        もっとbetterな処理方法があるはず。↓
        if self.userNameText == "" {
            self.userNameText = "ー"
        }
        if self.genderText == "" {
            self.genderText = "ー"
        }
        if self.ageText == "" {
            self.ageText = "ー"
        }
        if self.workText == "" {
            self.workText = "ー"
        }
        if self.introductionText == "" {
            self.introductionText = "ー"
        }
        if self.academicHistoryText == "" {
            self.academicHistoryText = "ー"
        }
        if self.hobbyText == "" {
            self.hobbyText = "ー"
        }
        if self.visitedCountryText == "" {
            self.visitedCountryText = "ー"
        }
        if self.wannaVisitCountryText == "" {
            self.wannaVisitCountryText = "ー"
        }
        if self.whereYouLiveText == "" {
            self.whereYouLiveText = "ー"
        }
        if self.birthdaytext == "" {
            self.birthdaytext = "ー"
        }
        if self.etcText == "" {
            self.etcText = "ー"
        }

        //        プロフィールデータをfirebaseへ保存（更新も可）
        let user = Auth.auth().currentUser
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(user!.uid)'sProfileDocument")
        let postDic = [
            "userName": self.userNameText!,
            "gender": self.genderText!,
            "age": self.ageText!,
            "work": self.workText!,
            "introduction": self.introductionText!,
            "academicHistory": self.academicHistoryText!,
            "hobby": self.hobbyText!,
            "visitedCountry": self.visitedCountryText!,
            "wannaVisitCountry": self.wannaVisitCountryText!,
            "whereYouLive": self.whereYouLiveText!,
            "birthday": self.birthdaytext!,
            "etc": self.etcText!,
        ] as [String: Any]
        print(postDic)
        postRef.setData(postDic, merge: true)

        let changeRequest = user!.createProfileChangeRequest()
        changeRequest.displayName = self.userNameText!
        changeRequest.commitChanges { error in
            if let error = error {
                // プロフィールの更新でエラーが発生
                print("DEBUG_PRINT: " + error.localizedDescription)
                return
            } else {
                print("DEBUG_PRINT: [displayName = \(user!.displayName!)]の設定に成功しました。")
            }
        }

        //        既存の投稿データのuserNameも変更する
        let postRef2 = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user!.uid)
        postRef2.getDocuments(completion: { querySnapshot, error in
            if let error = error {
                print("取得失敗\(error)")
            }
            if let querySnapshot = querySnapshot {
                print("取得成功\(querySnapshot)")
                self.postArrayForDocId = querySnapshot.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let docIdArray = PostData(document: document).documentId
                    return docIdArray
                }
                self.postArrayForDocId.forEach {
                    let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document($0)
                    postRef.updateData(["userName": self.userNameText!])
                }
                SVProgressHUD.showSuccess(withStatus: "保存しました")
                SVProgressHUD.dismiss(withDelay: 1.5, completion: { () in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        })
    }
}

/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
 }
 */
