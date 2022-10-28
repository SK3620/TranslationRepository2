//
//  editProfileViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/28.
//

import Firebase
import SVProgressHUD
import UIKit

class editProfileViewController: UIViewController {
    @IBOutlet var textField: UITextField!

    var StringArr: [String] = ["名前"]
    var indexPath_row: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.indexPath_row {
        case 0:
            self.title = self.StringArr[0]
        default:
            print("nil")
        }
    }

    @IBAction func saveButton(_: Any) {
        if let textField_text = self.textField.text {
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = textField_text
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        // キーボードを閉じる
        self.view.endEditing(true)
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
