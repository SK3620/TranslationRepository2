//
//  TranslateViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import Alamofire
import SVProgressHUD
import RealmSwift


class TranslateViewController: UIViewController, UITextViewDelegate {

    // DeepL APIのレスポンス用構造体
    struct DeepLResult: Codable {
        let translations: [Translation]
        struct Translation: Codable {
            var detected_source_language: String
            var text: String
        }
    }
    
    var textStringForButton2: String?
    var realm = try! Realm()
    var translationFolder: TranslationFolder?
    var translation: Translation!
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    
    @IBOutlet weak var translateTextView: UITextView!
    @IBOutlet weak var translateLabel: UITextView!
    
    
    @IBOutlet weak var languageLabel1: UILabel!
    @IBOutlet weak var languageLabel2: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    
    
   

    //    JSONデコード用（？）
    let decoder: JSONDecoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print("URL : \(Realm.Configuration.defaultConfiguration.fileURL!)")

        let borderColor = UIColor.gray.cgColor
        
        //  ボタンの画像サイズ変更
        imageButton1.imageView?.contentMode = .scaleAspectFill
        imageButton1.contentHorizontalAlignment = .fill
        imageButton1.contentVerticalAlignment = .fill
        
        imageButton2.imageView?.contentMode = .scaleAspectFill
        imageButton2.contentHorizontalAlignment = .fill
        imageButton2.contentVerticalAlignment = .fill
        
        translateTextView.layer.cornerRadius = 10
        translateTextView.clipsToBounds = true
        translateTextView.layer.borderColor = borderColor
        translateTextView.layer.borderWidth = 2
        
        button1.layer.cornerRadius = 10
        button1.layer.borderWidth = 2
        button1.layer.borderColor = borderColor
    
        button2.layer.cornerRadius = 10
        button2.layer.borderWidth = 2
        button2.layer.borderColor = borderColor
        button2.isEnabled = false
        button2.isHidden = true
        
        button3.layer.cornerRadius = 10
        button3.layer.borderWidth = 2
        button3.layer.borderColor = borderColor
        button3.setTitle("上記を保存", for: .normal)
        
        
        translateLabel.layer.cornerRadius = 10
        translateLabel.clipsToBounds = true
        translateLabel.layer.borderWidth = 2
        translateLabel.layer.borderColor = borderColor
       
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        languageLabel1.text = "日本語\nJapanese"
        languageLabel2.text = "英語\nEnglish"

//        translateTextView.delegate = self

        // Do any additional setup after loading the view.
        
//        if let textString = self.textStringForButton2{
//            button2.isHidden = false
//            button2.isEnabled = true
//            self.button2.setTitle("保存先▷\(textString)", for: .normal)
        
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        doneToolbar.items = [spacer, doneButton]
        let someArr = [self.translateTextView, self.translateLabel]
        for someNumber in someArr{
        someNumber!.inputAccessoryView = doneToolbar
        }
    }
    
    @objc func doneButtonTaped(sender: UIButton){
        translateTextView.endEditing(true)
        translateLabel.endEditing(true)
    }
    
   
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
       
        
        if let textString = self.textStringForButton2{
            let translationFolderArr2 = realm.objects(TranslationFolder.self)
            var FolderNameArr = [String]()
            for number in 0...translationFolderArr2.count - 1{
                FolderNameArr.append(translationFolderArr2[number].folderName)
            }
            if FolderNameArr.contains(textString){
                
                
                
                print("DEBUG : \(textString)")
                self.button2.setTitle("保存先▷\(textString)", for: .normal)
                self.button2.isHidden = false
                self.button2.isEnabled = true
                
                button3.setTitle("保存先を変更", for: .normal)
            } else {
                self.button3.setTitle("上記を保存", for: .normal)
                self.button2.isEnabled = false
                self.button2.isHidden = true
            }
        }
    }
    
    
    
    @IBAction func translateButton(_ sender: Any) {
        if self.translateTextView.text == "" {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "文字を入力して下さい")
            return
        } else if self.languageLabel1.text == "日本語\nJapanese" {
       translateJapanese()
        } else {
       translateEnglish()
        }
    }

        @IBAction func changeLanguageButton(_ sender: Any) {
            if languageLabel1.text == "日本語\nJapanese"{
            languageLabel1.text = "英語\nEnglish"
            languageLabel2.text = "日本語\nJapanese"
//            translateEnglish()
        } else {
            languageLabel1.text = "日本語\nJapanese"
            languageLabel2.text = "英語\nEnglish"
//            translateJapanese()
        }
    }
    
    
//    func textViewDidChange(_ textView: UITextView) {
//        if self.languageLabel1.text == "日本語"{
//        translateJapanese()
//        } else {
//            func translateEnglish(){
//            }
//        }
//    }
    
    func translateEnglish(){
        let authKey1 = KeyManager().getValue(key: "apiKey") as! String
        print("DEBUG : \(authKey1)")
        //            print結果　914cbb6c-40d6-0314-6e30-5fbd278de0ac:fx
        
        //            前後のスペースと改行を削除
        let authKey = authKey1.trimmingCharacters(in: .newlines)
        
        // APIリクエストするパラメータを作成
        let parameters: [String: String] = [
            "text": self.translateTextView.text,
            "auth_key": authKey,
            "source_lang" : "EN",
            "target_lang" : "JA"
        ]
    
        // ヘッダーを作成
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        // DeepL APIを実行
        AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self){ response in
            
            if case .success = response.result {
                do {
                    // 結果をデコード
                    let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
                    // 結果のテキストを取得&画面に反映
                    self.translateLabel.text =  result.translations[0].text
                  
                    // 結果をNCMBに保存する処理を呼び出し
                    //                                        saveResult()
                } catch {
                    debugPrint("デコード失敗")
                }
            } else {
                debugPrint("APIリクエストエラー")
            }
        }
    }
    
    func translateJapanese(){
//        if self.translateTextView.text.isEmpty{
//            SVProgressHUD.show()
//            SVProgressHUD.showError(withStatus: "翻訳したい文を入力して下さい")
//
//            return
//        }else{
            // APIKey.plistに保存したDeepLの認証キーを取得
          
            let authKey1 = KeyManager().getValue(key: "apiKey") as! String
            print("DEBUG : \(authKey1)")
            //            print結果　914cbb6c-40d6-0314-6e30-5fbd278de0ac:fx
            
            //            前後のスペースと改行を削除
            let authKey = authKey1.trimmingCharacters(in: .newlines)
            
            // APIリクエストするパラメータを作成
            let parameters: [String: String] = [
                "text": self.translateTextView.text,
                "auth_key": authKey,
                "source_lang" : "JA",
                "target_lang" : "EN"
            ]
        
            // ヘッダーを作成
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            // DeepL APIを実行
            AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self){ response in
                //                         リクエスト成功か判定
                //                    print("Reponse: \(response)")
                //                    switch(response.result){
                //                    case .success(let data):
                //                        print("url:\(data)")
                //                    case .failure(let error):
                //                        print("error:\(error)")
                //                    }
                //                }
                //        }
                //    }
                //}
                if case .success = response.result {
                    do {
                        // 結果をデコード
                        let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
                        // 結果のテキストを取得&画面に反映
                        self.translateLabel.text =  result.translations[0].text
                      
                        // 結果をNCMBに保存する処理を呼び出し
                        //                                        saveResult()
                    } catch {
                        debugPrint("デコード失敗")
                    }
                } else {
                    debugPrint("APIリクエストエラー")
                }
            }
    }
    
    @IBAction func ToFolderListViewControllerButton(_ sender: Any) {
        
        let folderListViewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderList") as! FolderListViewController
        
//        let folderListViewController = FolderListViewController()
//
//        if let sheet = folderListViewController.sheetPresentationController{
//            sheet.detents = [.medium()]
//        }
        
        folderListViewController.translateViewController = self
        
        present(folderListViewController, animated: true, completion: nil)
        
        print("セグエ")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FolderList" {
        let folderListViewController = segue.destination as! FolderListViewController
        folderListViewController.translateViewController = self
        }
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        if self.translateTextView.text != "" && self.translateLabel.text != "" {
            if let textStringForButton2 = self.textStringForButton2 {
                SVProgressHUD.show()
                let translateTextViewText = self.translateTextView.text
                let translateLabelText = self.translateLabel.text
                
                print(translateTextViewText!)
                print(translateLabelText!)
//                            Translationモデルのインスタンス作成
//                let result1 = Translation(value: ["inputData": "\(translateTextViewText!)"])
//                let result2 = Translation(value: ["resultData": "\(translateLabelText!)"])
                
                let result3 = Translation()
                result3.inputData = translateTextViewText!
                result3.resultData = translateLabelText! + "\n" + "メモ : "
                let allTranslation = realm.objects(Translation.self)
                if allTranslation.count != 0 {
                    result3.id = allTranslation.max(ofProperty: "id")! + 1
                }
                
//                let dictionary: [String: [[String: String]]] = ["results": [["inputData": "\(translateTextViewText!)"], ["resultData": "\(translateLabelText!)"]]
//                ]
//                print("辞書 : \(dictionary)"
//                let result3 = Translation(value: dictionary)
//                print("結果3 : \(result3)")
                let predict = NSPredicate(format: "folderName == %@", textStringForButton2)
                
                translationFolderArr = realm.objects(TranslationFolder.self).filter(predict)
                print("データ : \(translationFolderArr)")
                
                try! realm.write{
                    translationFolderArr.first!.results.append(result3)
                }
//                ここに追加しました。Translationクラスのid設定はここではだめ
//                let translation = Translation()
//                let allTranslation = realm.objects(Translation.self)
//                if allTranslation.count != 0 {
//                  translation.id = allTranslation.max(ofProperty: "id")! + 1
//                }
                
                let result4 = Histroy()
                
                let allHistory = self.realm.objects(Histroy.self)
                if allHistory.count != 0 {
                    result4.id = allHistory.max(ofProperty: "id")! + 1
                }
                
                let date2 = Date()
                
                try! realm.write{
                    result4.inputData2 = translateTextViewText!
                    result4.resultData2 = translateLabelText!
                    result4.date2 = date2
                    self.realm.add(result4)
                }
                
                
                
                
                print("データ : \(translationFolderArr)")
                SVProgressHUD.showSuccess(withStatus: "'\(textStringForButton2)' へ保存しました")
                
                if self.translateTextView.layer.borderWidth == 2.5 {
                    
                    self.translateTextView.layer.borderWidth = 2
                    self.translateTextView.layer.borderColor = UIColor.gray.cgColor
                }
                
                if self.translateLabel.layer.borderWidth == 2.5 {
                    
                    self.translateLabel.layer.borderWidth = 2
                    self.translateLabel.layer.borderColor = UIColor.gray.cgColor
                }
            }
            
        } else if self.translateTextView.text == "" && self.translateLabel.text == "" {
            error1()
            error2()
        } else if self.translateTextView.text == "" {
            error1()
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力して下さい")
        } else {
            error2()
        }
    }
    
    func error1(){
        
        let borderColor1 = UIColor.red.cgColor
        self.translateTextView.layer.borderWidth = 2.5
        self.translateTextView.layer.borderColor = borderColor1
        
    }
    
    func error2(){
        SVProgressHUD.show()
        let borderColor1 = UIColor.red.cgColor
        self.translateLabel.layer.borderWidth = 2.5
        self.translateLabel.layer.borderColor = borderColor1
        SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力して下さい")
    }
    
    
    @IBAction func deleteButton1(_ sender: Any) {
        self.translateTextView.text = ""
    }
    
    @IBAction func deleteButton2(_ sender: Any) {
        self.translateLabel.text = ""
    }
    
    //
    //    taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    ////        データを取得する。
    //    let predict = NSPredicate(format: "category == %@", taskSearchBar.text!)
    //    taskArray = taskArray.filter(predict)
    //    print(taskArray)
    //    let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment")
    //        if let sheet = commentViewController?.sheetPresentationController {
    //            sheet.detents = [.medium()]
    //        }
    //        present(commentViewController!, animated: true, completion: nil)
    //    }}
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
