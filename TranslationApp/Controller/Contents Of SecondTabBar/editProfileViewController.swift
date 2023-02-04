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
    @IBOutlet private var tableView: UITableView!

    private var textFieldArr: [UITextField]! = []
    private var textViewArr: [UITextView]! = []
    
    private var textFieldAndView_textArr: [String] = []

    var postArrayForDocId: [String] = []

    var profileViewController: ProfileViewController!
    var secondTabBarController: SecondTabBarController!

    var profileData: [String: Any] = [:]

    private var userNameText: String?
    private var genderText: String?
    private var ageText: String?
    private var workText: String?
    private var introductionText: String?
    private var academicHistoryText: String?
    private var hobbyText: String?
    private var visitedCountryText: String?
    private var wannaVisitCountryText: String?
    private var whereYouLiveText: String?
    private var birthdaytext: String?
    private var etcText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsForNavigationBarAppearence()
        
        self.settingsForNaivigationControllerAndBar()
        
        self.settingsForTableView()
     
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
        }
    }
    
    private func settingsForNavigationBarAppearence(){
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func settingsForNaivigationControllerAndBar(){
        self.secondTabBarController.navigationController?.setNavigationBarHidden(true, animated: false)
        self.profileViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        let rightBarButtonItem = UIBarButtonItem(title: "保存する", style: .done, target: self, action: nil)
        self.profileViewController.navigationController?.navigationItem.rightBarButtonItems = [rightBarButtonItem]
        self.title = "プロフィール編集"
    }
    
    private func settingsForTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForEditProfile", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
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

        self.textFieldArr = [cell.userNameTextField, cell.genderTextField, cell.ageTextField, cell.workTextField, cell.whereYouLiveTextField, cell.birthdayTextField]
        self.textViewArr = [cell.introductionTextView, cell.academicHistoryTextView, cell.hobbyTextView, cell.visitedCountryTextView, cell.wannaVisitCountryTextView, cell.etcTextView]
        self.setDoneToolBar(textFieldArr: self.textFieldArr, textViewArr: self.textViewArr)

        cell.setProfileData(profileData: self.profileData)

        return cell
    }

   private func setDoneToolBar(textFieldArr: [UITextField]!, textViewArr: [UITextView]!) {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
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
        SVProgressHUD.show()

        self.userNameText = self.textFieldArr[0].text
        if self.userNameText == "" || self.userNameText == "ー" {
            SVProgressHUD.showError(withStatus: "名前を入力してください")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }

        self.genderText = self.textFieldArr[1].text
        self.ageText = self.textFieldArr[2].text
        self.workText = self.textFieldArr[3].text
        self.introductionText = self.textViewArr[0].text
        self.academicHistoryText = self.textViewArr[1].text
        self.hobbyText = self.textViewArr[2].text
        self.visitedCountryText = self.textViewArr[3].text
        self.wannaVisitCountryText = self.textViewArr[4].text
        self.whereYouLiveText = self.textFieldArr[4].text
        self.birthdaytext = self.textFieldArr[5].text
        self.etcText = self.textViewArr[5].text

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
        postRef.setData(postDic, merge: true, completion: { error in
            if let error = error {
                print(error)
            } else {
                self.updateUserNameOfPostsDocuments(user: user!, userName: self.userNameText!)
                self.updateUserNameOfCommentsDocuments(user: user!, userName: self.userNameText!)
                self.updateUserNameOfChatListsDocument(user: user!)
            }
        })

        //also update display name
        self.updateDisplayName(user: user!, userNameText: self.userNameText!)

        // also change the userName of the existing posted data
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

   private func updateUserNameOfPostsDocuments(user: User, userName: String) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).whereField("uid", isEqualTo: user.uid)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("userNameのupdateに失敗\(error)")
            }
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let doc = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document(queryDocumentSnapshot.documentID)
                    doc.updateData(["userName": userName]) { error in
                        if let error = error {
                            print("userNameのupdateに失敗\(error)")
                        } else {
                            print("userNameのupdateに成功")
                        }
                    }
                }
            }
        }
    }

   private func updateUserNameOfCommentsDocuments(user: User, userName: String) {
        let postsRef = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).whereField("uid", isEqualTo: user.uid)
        postsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("userNameのupdateに失敗\(error)")
            }
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let doc = Firestore.firestore().collection(FireBaseRelatedPath.commentsPath).document(queryDocumentSnapshot.documentID)
                    doc.updateData(["userName": userName]) { error in
                        if let error = error {
                            print("userNameのupdateに失敗\(error)")
                        } else {
                            print("userNameのupdateに成功")
                        }
                    }
                }
            }
        }
    }

   private func updateUserNameOfChatListsDocument(user: User) {
        let chatListsRef = Firestore.firestore().collection("chatLists").whereField("members", arrayContains: user.uid)
        chatListsRef.getDocuments { querySnapshot, error in
            if let error = error {
                print(error)
            }
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { queryDocumentSnapshot in
                    let firstMemberUid = ChatList(queryDocumentSnapshot: queryDocumentSnapshot).chatMembers![0]
                    let secondMemberUid = ChatList(queryDocumentSnapshot: queryDocumentSnapshot).chatMembers![1]
                    let documentId = queryDocumentSnapshot.documentID
                    self.seoncdUpdateUserName(firstMemberUid: firstMemberUid, seoncdMemberUid: secondMemberUid, docId: documentId)
                }
            }
        }
    }

   private func seoncdUpdateUserName(firstMemberUid: String, seoncdMemberUid: String, docId: String) {
        let firstProfileDataRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(firstMemberUid)'sProfileDocument")
        firstProfileDataRef.getDocument { documentSnapshot, error in
            if let error = error {
                print(error)
            }
            if let documentSnapshot = documentSnapshot {
                let firstUserName = ProfileData(documentSnapshot: documentSnapshot).userName

                let secondProfileDataRef = Firestore.firestore().collection(FireBaseRelatedPath.profileData).document("\(seoncdMemberUid)'sProfileDocument")
                secondProfileDataRef.getDocument { documentSnapshot, error in
                    if let error = error {
                        print(error)
                    }
                    if let documentSnapshot = documentSnapshot {
                        let secondUserName = ProfileData(documentSnapshot: documentSnapshot).userName
                        self.thirdUpdateUserName(firstUserName: firstUserName!, secondUserName: secondUserName!, docId: docId)
                    }
                }
            }
        }
    }

   private func thirdUpdateUserName(firstUserName: String, secondUserName: String, docId: String) {
        let chatListsRef = Firestore.firestore().collection("chatLists").document(docId)
        chatListsRef.updateData(["membersName": [firstUserName, secondUserName]]) { error in
            if let error = error {
                print(error)
            } else {
                print("userNameのupdate成功")
            }
        }
    }
    
    private func updateDisplayName(user: User, userNameText: String){
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = userNameText
        changeRequest.commitChanges { error in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                return
            } else {
                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
            }
        }
    }
}
