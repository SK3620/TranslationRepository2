//
//  RirekiViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/13.
//

import UIKit
import RealmSwift

class RirekiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  
    @IBOutlet weak var rirekiTableView: UITableView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var label1: UILabel!
    
    let realm = try! Realm()
    var historyArr: Results<Histroy> = try! Realm().objects(Histroy.self).sorted(byKeyPath: "date2", ascending: true)
    
    var intArr = [Int]()
    var inputDataCopy: String!
    var resultDataCopy: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.text = "左スワイプで削除"
        
        let borderColor = UIColor.gray.cgColor
        button1.layer.borderColor = borderColor
        button1.layer.borderWidth = 2.5
        button1.layer.cornerRadius = 10
        
        button1.isEnabled = false
        
        rirekiTableView.delegate = self
        rirekiTableView.dataSource = self

        let nib = UINib(nibName: "CustomCellTableViewCell", bundle: nil)
        rirekiTableView.register(nib, forCellReuseIdentifier: "CustomCell")
        print("登録されてます")
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.historyArr = realm.objects(Histroy.self).sorted(byKeyPath: "date2", ascending: true)
        self.rirekiTableView.reloadData()
        
        confirm()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCellTableViewCell
        
        let historyArr2 = historyArr[indexPath.row]
        
        let inputData2 = historyArr2.inputData2
        let resultData2 = historyArr2.resultData2
        
        let date2 = historyArr2.date2
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: date2)
        
        cell.setData(inputData2, resultData2, dateString, indexPath.row + 1)
        
//        buttonにタグを設定　tapされたボタンのcellを判定 addTargetを追加
        cell.copyButton.addTarget(self, action: #selector(tapCellButton(_:)), for: .touchUpInside)
        cell.copyButton.tag = indexPath.row
      
        return cell
    }
    
    @objc func tapCellButton(_ sender: UIButton){
//        外部引数_にはたっぷされたボタン自体が入る そいつがsenderでsenderはUIButtonが持つtagプロパティを利用する
        UIPasteboard.general.string = self.historyArr[sender.tag].inputData2 + "\n" + "\n" + self.historyArr[sender.tag].resultData2
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyArr.count
      }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
//    deleteボタンが押された時
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            データベースから削除する
            try! realm.write  {
                self.realm.delete(self.historyArr[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            confirm()
            tableView.reloadData()
        }
    }

    @IBAction func button1Action(_ sender: Any) {
        
        let alert = UIAlertController(title: "履歴の削除", message: "本当に全ての履歴を削除してもよろしいですか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style:.default, handler: {(action) -> Void in  for number1 in 1...self.historyArr.count{
            var number2 = number1
            number2 = 0
            self.intArr.append(number2)
            print(self.intArr)
        }
            
            do {
                let realm = try Realm()
                try realm.write{
                    for number3 in self.intArr{
                        realm.delete(self.historyArr[number3])
                    }
                }
            } catch {
                print("エラー")
            }
            self.intArr = []
            self.historyArr = self.realm.objects(Histroy.self)
            
            self.button1.isEnabled = false
            self.label1.isHidden = true
            
            self.rirekiTableView.reloadData()
            print("リロードされた")
            
        })
        //        handlerで削除orキャンセルボタンが押された時に実行されるメソッドを実装
        let cencel = UIAlertAction(title: "キャンセル", style: .default, handler: {(action) -> Void in print("キャンセルボタンがタップされた。")
        })
        
        alert.addAction(delete)
        alert.addAction(cencel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    //
    //        for number in 0...self.historyArr.count - 1{
    //            try! realm.write{
    //                print("確認 : \(number)")
    //                self.realm.delete(self.historyArr[number])
    //                print("削除")
    //            }
    //        }
    
    
    
    //
    //                    try! realm.write{
    //                        for number in 0...2 {
    //                            self.realm.delete(self.historyArr[number])
    //                        }
    //                    }
    //
    
    
  

func confirm(){
    if self.historyArr.count == 0 {
        button1.isEnabled = false
        label1.isHidden = true
    } else {
        button1.isEnabled = true
        label1.isHidden = false
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

