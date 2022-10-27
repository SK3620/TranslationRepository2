//
//  TimeLineViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/27.
//

import Firebase
import UIKit

class TimeLineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.backgroundColor = .systemGray4
    }

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)
//        currentUserがnilなら
        if Auth.auth().currentUser == nil {
//            ログインしていない時の処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
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
}
