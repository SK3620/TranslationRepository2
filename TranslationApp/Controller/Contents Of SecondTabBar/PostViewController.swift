//
//  PostViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/11/03.
//

import Firebase
import SVProgressHUD
import UIKit

class PostViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var label1: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "タイムライン"
        self.textView.endEditing(false)
        // 決定バーの生成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.done))
        toolbar.setItems([spaceItem, doneItem], animated: true)
        // インプットビュー設定
        self.textView.inputAccessoryView = toolbar
        // Do any additional setup after loading the view.
    }

    @objc func done() {
        self.textView.endEditing(true)
    }

//    投稿ボタン
    @IBAction func postButton(_: Any) {
        SVProgressHUD.show()
        if self.textView.text.isEmpty {
            SVProgressHUD.showError(withStatus: "投稿内容を入力してください")
            return
        }

        let user = Auth.auth().currentUser!
        let postRef = Firestore.firestore().collection(FireBaseRelatedPath.PostPath).document()
        let postDic = [
            "contentOfPost": self.textView.text!,
            "postedDate": FieldValue.serverTimestamp(),
            "userName": user.displayName!,
            "uid": user.uid,
        ] as [String: Any]
        postRef.setData(postDic)
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
    }

    @IBAction func backButton(_: Any) {
        self.dismiss(animated: true)
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
