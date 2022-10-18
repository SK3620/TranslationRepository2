//
//  SettingsViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/10/12.
//

import UIKit



class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var delegate: SettingsDelegate!
    @IBOutlet weak var tableView: UITableView!
    
    var menuArr: [String] = ["単語・フレーズ", "学習記録", "メモ", "閉じる"]
    var delegate: SettingsDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationController?.navigationBar.barTintColor = .systemGray6
        self.navigationController?.navigationBar.backgroundColor = .systemGray6
        self.title = "メニュー"
        self.navigationController?.navigationBar.titleTextAttributes = [
//文字の色
            .foregroundColor: UIColor.black
            ]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.menuArr[indexPath.row]
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
        delegate.tappedSettingsItem(indexPath: indexPath)
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
