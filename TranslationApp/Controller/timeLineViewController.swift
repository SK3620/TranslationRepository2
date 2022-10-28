//
//  timeLineViewController.swift
//
//
//  Created by 鈴木健太 on 2022/10/27.
//

import Firebase
import SVProgressHUD
import UIKit

class timeLineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        アカウントがなければ、UIAlertを出して、パスワードとメールを入力させる
        if let user = Auth.auth().currentUser {
            return
        } else {}
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
