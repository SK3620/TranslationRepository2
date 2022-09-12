
//  History2ViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/09/01.


import UIKit
import RealmSwift
import SVProgressHUD

class History2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var memoButton: UIButton!
    
    
    
    let realm = try! Realm()
    var translationFolderArr: Results<TranslationFolder>!
    
    var folderNameString: String = ""
    var expandSectionSet = Set<Int>()
    var sections = [String]()
    var tableDataList = [String]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("確認11 : \(self.folderNameString)")
        
        
        //        xibファイルの登録
        let nib = UINib(nibName: "CustomHeaderFooterView", bundle: nil)
        //        再利用するための準備　ヘッダーの登録
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "Header")
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        let borderColor = UIColor.gray.cgColor
        memoButton.layer.borderColor = borderColor
        memoButton.layer.borderWidth = 3
        memoButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("お呼ばれしました。")
        
        self.folderNameLabel.text = self.folderNameString
        
        tableView.layer.cornerRadius = 10
        
        print("確認10 : \(self.folderNameString)")
        
        self.translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
        
        let predict = NSPredicate(format: "folderName == %@", self.folderNameString)
        translationFolderArr = self.translationFolderArr.filter(predict)
        
        self.sections = []
        self.tableDataList = []
        
        for number in 0...translationFolderArr[0].results.count - 1 {
            self.sections.append(translationFolderArr[0].results[number].inputData)
            self.tableDataList.append(translationFolderArr[0].results[number].resultData)
        }
        
        tableView.reloadData()
        
        for i in sections{
            print("配列 \(i)")
        }
        
        for a in tableDataList{
            print("配列2 \(a)")
        }
        
       
    }
    
    
    
    
    //    開閉時の表示処理をする
    //    あとはセクションの開閉の表示処理をしてやるだけです。閉じてるセクションでは row の数を0にしてやればいい感じになる
    
    
    func  numberOfSections(in tableView: UITableView) -> Int {
        print("確認7 : \(translationFolderArr!)")
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandSectionSet.contains(section) ? 1 : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableDataList[indexPath.section]
        
        let image1 = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        let image2 = UIImage(systemName: "hand.tap", withConfiguration: image1)
        cell.imageView?.image = image2

        cell.textLabel?.numberOfLines = 0
       
        return cell
    }
    
    //    UItableViewDelegateテーブルビューの指定されたセクションのヘッダに表示するビューをデリゲートに要求します。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("確認16 tableView始め")
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! CustomHeaderFooterView
            header.section = section
        header.inputDataLabel.text = String(section + 1) + ": " + sections[section]
    //        セクション保持
            header.delegate = self
//        headerの型はCustomHeaderFooterViewクラス型で、そのクラスには、delegateプロパティが宣言されている。そのdelegateプロぱにSingleAcordiontableViewHeaderFooterViewDelegate型（こいつはプロトコル）を指定している。このプロトコルには、一つのメソッドが定義されている。
        
        print("確認16 tableView終わり")
    //        デリゲート設定
            return header
//        headerはCVustomHeaderFooterViewクラスで、このクラスはUIViewクラスを継承したUITableViewHeaderFooterViewを継承しているからreturn headerできる。
        }
    
    @IBAction func backButtton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
        
//        .deleteだけでもよき
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
//            tableDataList.remove(at: indexPath.section * 2 + 1)
//            sections.remove(at: indexPath.section * 2)
            
            try! realm.write {
                self.realm.delete(self.translationFolderArr[0].results[indexPath.section])
                sections.remove(at: indexPath.section)
                tableDataList.remove(at: indexPath.section)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "Edit1") as! Edit1ViewController
        
        editViewController.textView1String = translationFolderArr[0].results[indexPath.section].inputData
        editViewController.textView2String = translationFolderArr[0].results[indexPath.section].resultData
        editViewController.translationIdNumber = translationFolderArr[0].results[indexPath.section].id

//        if let sheet = editViewController?.sheetPresentationController {
//            sheet.detents = [.medium()]
//        }
        
        present(editViewController, animated: true, completion: nil)
        
        
        
//        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment")
        //        if let sheet = commentViewController?.sheetPresentationController {
        //            sheet.detents = [.medium()]
        //        }
        //        present(commentViewController!, animated: true, completion: nil)
    }
    
    @IBAction func memoButtonAction(_ sender: Any) {
        
        let memoViewController = storyboard?.instantiateViewController(withIdentifier: "MemoView") as! MemoViewController
        
        if let sheet = memoViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        memoViewController.folderNameString = self.folderNameString
        
        present(memoViewController, animated: true, completion: nil)
    }
    

}

extension History2ViewController: SingleAccordionTableViewHeaderFooterViewDelegate{
    
//   開いているセクション情報を保持する。 テーブルを実装している ViewController でどこのセクションが開いていてどこが閉じているのかという情報を保持しないといけません。

//    こいつで開いているセクションを保持
//    セクションタップ時に呼ばれる
    func singleAccordionTableViewHeaderFooterView(_ header: CustomHeaderFooterView, section: Int) {
        if expandSectionSet.contains(section){
            expandSectionSet.remove(section)
        } else {
            expandSectionSet.insert(section)
            print("確認16 extensionはじめ")
        }
//        上記のようにカスタムセクションのデリゲートでセクションの開閉状態を保持します。
        //    セクションタップ時に指定のセクションのリロード処理を呼んであげます。
            tableView.reloadSections([section], with: .automatic)
        
        print("確認16 extension終わり")
    }
    
    
}


