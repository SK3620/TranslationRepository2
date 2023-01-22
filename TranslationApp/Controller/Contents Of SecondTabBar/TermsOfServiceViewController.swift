//
//  TermsOfServiceViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2023/01/22.
//

import UIKit

class TermsOfServiceViewController: UIViewController {
    @IBOutlet private var agreeButton: UIButton!
    @IBOutlet private var disagreeButton: UIButton!

    @IBOutlet private var tableView: UITableView!

    var loginViewController: LoginViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "利用規約"

        self.settingsForTableView()

        self.settingsForNavigationBarAppearence()

        self.designForButtons(buttons: [self.agreeButton, self.disagreeButton])
    }

    private func settingsForTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "CustomCellForTermsOfService", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        self.tableView.reloadData()
    }

    private func settingsForNavigationBarAppearence() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemGray6
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func designForButtons(buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 2.0
        }
    }

    @IBAction func agreeButton(_: Any) {
        self.dismiss(animated: true) {
            self.loginViewController.createAccount()
        }
    }

    @IBAction func disagreeButton(_: Any) {
        self.dismiss(animated: true)
    }
}

extension TermsOfServiceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        print("実行！")
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        return cell
    }
}
