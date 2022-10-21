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
import ContextMenuSwift
import AVFoundation

class TranslateViewController: UIViewController, UITextViewDelegate {
    
    // DeepL APIのレスポンス用構造体
    //    Codableとは、API通信等で取得したJSONやプロパティリストを任意のデータ型に変換するプロトコル →データをアプリを実装しやすいデータ型に変換することで処理が楽になる
    //    データ型とは要は、StringやIntのこと　swiftで扱えるようにする
    
    
    //    APIから取得したデータをJSONで受け取って、swiftで使えれるようにCodableで構造体に変換します。
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
    
    var tabBarController1: TabBarController!
    
    @IBOutlet weak var translateTextView: UITextView!
    @IBOutlet weak var translateLabel: UITextView!
    @IBOutlet weak var label1: UILabel!
    
    
    @IBOutlet weak var languageLabel1: UILabel!
    @IBOutlet weak var languageLabel2: UILabel!
    
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var copyButton1: UIButton!
    @IBOutlet weak var copyButton2: UIButton!
    @IBOutlet weak var volumeButton1: UIButton!
    @IBOutlet weak var volumeButton2: UIButton!
    @IBOutlet weak var deleteTextButton1: UIButton!
    @IBOutlet weak var deleteTextButton2: UIButton!
    
    var talker = AVSpeechSynthesizer()
    
    var numberForVolumeButton2: Int = 0
    
    
    
    
    
    
    //    JSONデコード用（？）
    let decoder: JSONDecoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("URL : \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
       
        
        label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
       
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .medium)
        let systemIcon = UIImage(systemName: "square.and.arrow.down", withConfiguration: config)
        button5.setImage(systemIcon, for: .normal)
        button5.layer.borderColor = UIColor.systemBlue.cgColor
        button5.layer.borderWidth = 1
        button5.layer.cornerRadius = 10
        
        let config1 = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        let systemIconForCopy = UIImage(systemName: "doc.on.doc", withConfiguration: config1)
        copyButton1.setImage(systemIconForCopy, for: .normal)
        copyButton2.setImage(systemIconForCopy, for: .normal)
        let systemIconForVolume = UIImage(systemName: "volume.3", withConfiguration: config1)
        volumeButton1.setImage(systemIconForVolume, for: .normal)
        volumeButton2.setImage(systemIconForVolume, for: .normal)
        let systemIconForDeleteText = UIImage(systemName: "delete.left", withConfiguration: config1)
        deleteTextButton1.setImage(systemIconForDeleteText, for: .normal)
        deleteTextButton2.setImage(systemIconForDeleteText, for: .normal)


        
        let borderColor = UIColor.systemGray4.cgColor
        
       
        translateTextView.clipsToBounds = true
        translateTextView.layer.borderColor = borderColor
        translateTextView.layer.borderWidth = 2
        
        button1.layer.cornerRadius = 10
        button1.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.systemBlue.cgColor
        
                button2.layer.cornerRadius = 10
                button2.layer.borderWidth = 1
        button2.layer.borderColor = UIColor.systemBlue.cgColor
                button2.isEnabled = false
                button2.isHidden = true
                button2.titleLabel?.numberOfLines = 1
        
        //        // ボタンの横幅に応じてフォントサイズを自動調整する設定
                button2.titleLabel?.adjustsFontSizeToFitWidth = true
       
        button4.layer.cornerRadius = 10
        button4.layer.borderWidth = 1
        button4.layer.borderColor = UIColor.systemBlue.cgColor
        
        
        translateLabel.clipsToBounds = true
        translateLabel.layer.borderWidth = 2
        translateLabel.layer.borderColor = borderColor
        
        view1.layer.borderWidth = 2
        view1.layer.borderColor = borderColor
        
        view2.layer.borderWidth = 2
        view2.layer.borderColor = borderColor
        
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        languageLabel1.text = "Japanese"
        languageLabel2.text = "English"
        
        translateTextView.delegate = self
        
        // Do any additional setup after loading the view.
        
                if let textString = self.textStringForButton2{
                    button2.isHidden = false
                    button2.isEnabled = true
                    self.button2.setTitle("\(textString)　へ保存する", for: .normal)
    }
        
        //キーボードに完了のツールバーを作成
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        
        // 左側のBarButtonItemはflexibleSpace。これがないと右に寄らない。flexibleSpaceはBlank space to add between other items
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(doneButtonTaped))
        //        The items displayed on the toolbar.
        doneToolbar.items = [spacer, doneButton]
        let someArr = [self.translateTextView, self.translateLabel]
        for someNumber in someArr{
            //            // textViewのキーボードにツールバーを設定
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
        
        self.tabBarController1.setBarButtonItem0()
        tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let textString = self.textStringForButton2{
            let translationFolderArr2 = realm.objects(TranslationFolder.self)
            var FolderNameArr = [String]()
            if translationFolderArr2.count == 0 {
                                self.button2.isEnabled = false
                                self.button2.isHidden = true
//                                self.button3.setTitle("上記を保存", for: .normal)
                return
            } else {
                for number in 0...translationFolderArr2.count - 1{
                    FolderNameArr.append(translationFolderArr2[number].folderName)
                }
            }
            if FolderNameArr.contains(textString){
                
                
                
                print("DEBUG : \(textString)")
                self.button2.setTitle("保存先▷\(textString)", for: .normal)
                self.button2.isHidden = false
                self.button2.isEnabled = true
                
               
            } else {
                
                self.button2.isEnabled = false
                self.button2.isHidden = true
            }
            
        }
    }
    
    
    
    
    @IBAction func translateButton(_ sender: Any) {
            if self.translateTextView.text == "" {
                SVProgressHUD.show()
                SVProgressHUD.showError(withStatus: "赤枠内にテキストを入力して、翻訳して下さい")
                translateTextView.layer.borderColor = UIColor.red.cgColor
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: changeIcon)
                return
            } else if self.languageLabel1.text == "Japanese" {
                translateJapanese()
            } else {
                translateEnglish()
            }
        }
        
        @IBAction func changeLanguageButton(_ sender: Any) {
            if languageLabel1.text == "Japanese"{
                languageLabel1.text = "English"
                languageLabel2.text = "Japanese"
                
            } else {
                languageLabel1.text = "Japanese"
                languageLabel2.text = "English"
                
            }
        }
        
        
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == translateTextView {
            if translateTextView.text != "" {
                self.label1.text = ""
            } else {
                self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
            }
            
            
            if self.languageLabel1.text == "Japanese"{
                translateJapanese()
            } else {
                translateEnglish()
            }
        }
    }
        
        
        func translateEnglish(){
            let authKey1 = KeyManager().getValue(key: "apiKey") as! String
            print("DEBUG : \(authKey1)")
            //            print結果　914cbb6c-40d6-0314-6e30-5fbd278de0ac:fx
            
            //            前後のスペースと改行を削除
            let authKey = authKey1.trimmingCharacters(in: .newlines)
            
            // APIリクエストするパラメータを作成　リクエストするために必要な情報を定義　リクエスト成功時に、翻訳結果が返される
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
            // DeepL APIリクエストを実行
            //        AF = Almofireのこと
            //        Almofireはapi情報を取得するための便利なライブラリ　通常はswift側で用意されているURLSessionを使う。
            //        requestメソッドでAPIを呼ぶ
            AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self){ response in
                
                if case .success = response.result {
                    do {
                        // 結果をデコード
                        //                    一般的に、アプリがAPIサーバーと通信する場合、データはJSON形式でやりとりすることが多いかと思います。Foundationフレームワークの JSONEncoder クラスを使用すると、Swiftの値をJSONに変換することができ、JSONDecoder クラスはJSONをSwiftの値にデコードすることができます
                        let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
                        // 結果のテキストを取得&画面に反映
                        self.translateLabel.text =  result.translations[0].text
                        
                    } catch {
                        debugPrint("デコード失敗")
                    }
                } else {
                    debugPrint("APIリクエストエラー")
                }
            }
        }
        
        func translateJapanese(){
        
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
                   
                    let predict = NSPredicate(format: "folderName == %@", textStringForButton2)
                    translationFolderArr = realm.objects(TranslationFolder.self).filter(predict)
                    
                    let result3 = Translation()
                    result3.inputData = translateTextViewText!
                    result3.resultData = translateLabelText! + "\n" + "メモ : "
                    result3.inputAndResultData = translateTextViewText! + result3.resultData
                    let allTranslation = realm.objects(Translation.self)
                    if allTranslation.count != 0 {
                        result3.id = allTranslation.max(ofProperty: "id")! + 1
                    }
                    
                    
                    try! realm.write{
                        translationFolderArr.first!.results.append(result3)
                    }
                    
                  
                    
                  
                    
                    
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
                        result4.inputAndResultData = translateTextViewText! + translateLabelText!
                        self.realm.add(result4)
                    }
                    
                    
                    
                    
                   
                    SVProgressHUD.showSuccess(withStatus: "'\(textStringForButton2)' へ保存しました")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: showDismiss)
                    
                    if self.translateTextView.layer.borderWidth == 2 {
                        
                        self.translateTextView.layer.borderWidth = 2
                        self.translateTextView.layer.borderColor = UIColor.systemGray4.cgColor
                    }
                    
                    if self.translateLabel.layer.borderWidth == 2 {
                        
                        self.translateLabel.layer.borderWidth = 2
                        self.translateLabel.layer.borderColor = UIColor.systemGray4.cgColor
                    }
                }
                
            } else if self.translateTextView.text == "" && self.translateLabel.text == "" {
                error1()
                error2()
            } else if self.translateTextView.text == "" {
                error1()
                SVProgressHUD.show()
                SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力してください")
            } else {
                error2()
            }
        }
    
    func showDismiss(){
        SVProgressHUD.dismiss()
    }
        
        func error1(){
            
            let borderColor1 = UIColor.red.cgColor
            self.translateTextView.layer.borderWidth = 2
            self.translateTextView.layer.borderColor = borderColor1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: changeIcon)
            
        }
        
        func error2(){
            SVProgressHUD.show()
            let borderColor1 = UIColor.red.cgColor
            self.translateLabel.layer.borderWidth = 2
            self.translateLabel.layer.borderColor = borderColor1
            SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力してください")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: changeIcon)
        }
        
        
        func changeIcon(){
            let borderColor1 = UIColor.systemGray4.cgColor
            self.translateTextView.layer.borderWidth = 2
            self.translateTextView.layer.borderColor = borderColor1
            
            self.translateLabel.layer.borderWidth = 2
            self.translateLabel.layer.borderColor = borderColor1
            
            SVProgressHUD.dismiss()
        }
        
        
        
        
        @IBAction func deleteButton1(_ sender: Any) {
            self.translateTextView.text = ""
            self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
        }
        
        @IBAction func deleteButton2(_ sender: Any) {
            self.translateLabel.text = ""
        }
    
    @IBAction func selectFolderButton(_ sender: Any) {
        let folderListViewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderList") as! FolderListViewController
        
        
        if let sheet = folderListViewController.sheetPresentationController{
            sheet.detents = [.medium()]
        }
        folderListViewController.translateViewController = self
        present(folderListViewController, animated: true, completion: nil)
        
    }
    
        
       
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    
    func setStringForButton2(){
        
        self.tabBarController1.setBarButtonItem0()
        tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if let textString = self.textStringForButton2{
            let translationFolderArr2 = realm.objects(TranslationFolder.self)
            var FolderNameArr = [String]()
            if translationFolderArr2.count == 0 {
                self.button2.isEnabled = false
                self.button2.isHidden = true
                //
                return
            } else {
                for number in 0...translationFolderArr2.count - 1{
                    FolderNameArr.append(translationFolderArr2[number].folderName)
                }
            }
            if FolderNameArr.contains(textString){
                
                
                
                print("DEBUG : \(textString)")
                self.button2.setTitle("保存先▷\(textString)", for: .normal)
                self.button2.isHidden = false
                self.button2.isEnabled = true
                
                            } else {
                
                self.button2.isEnabled = false
                self.button2.isHidden = true
            }
            
        }
    }
    
    @IBAction func copyButton1(_ sender: Any) {
        UIPasteboard.general.string = self.translateTextView.text
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
               self.copyButton1.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: chageCopyIcon)
    }
    
    @IBAction func copyButton2(_ sender: Any) {
        UIPasteboard.general.string = self.translateLabel.text
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
               self.copyButton2.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: chageCopyIcon)
    }
    
    func chageCopyIcon(){
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
               self.copyButton1.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: config), for: .normal)
        self.copyButton2.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: config), for: .normal)
    }
    
    @IBAction func volumeButton1(_ sender: Any) {
        
        let english = ContextMenuItemWithImage(title: "英語", image: UIImage())
        let japanese = ContextMenuItemWithImage(title: "日本語", image: UIImage())
        let stop = ContextMenuItemWithImage(title: "停止", image: UIImage())
        
        CM.items = [english, japanese, stop]
        CM.showMenu(viewTargeted: self.translateTextView, delegate: self, animated: true)
        
        self.numberForVolumeButton2 = 0
    }
    
    @IBAction func volumeButton2(_ sender: Any) {
        let english = ContextMenuItemWithImage(title: "英語", image: UIImage())
        let japanese = ContextMenuItemWithImage(title: "日本語", image: UIImage())
        let stop = ContextMenuItemWithImage(title: "停止", image: UIImage())
        
        CM.items = [english, japanese, stop]
        CM.showMenu(viewTargeted: self.translateLabel, delegate: self, animated: true)
        
        self.numberForVolumeButton2 = 1
    }
    
}
    


extension TranslateViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) -> Bool {
        
        switch index {
        case 0:
            if self.numberForVolumeButton2 == 0 {
            let englishText = self.translateTextView.text!
//                話す内容をセット
                         let utterance = AVSpeechUtterance(string: englishText)
             //            言語を英語に設定
                         utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
             //            実行
                         self.talker.speak(utterance)
            } else {
                self.numberForVolumeButton2 = 0
                let englishText = self.translateLabel.text!
//                話す内容をセット
                         let utterance = AVSpeechUtterance(string: englishText)
             //            言語を英語に設定
                         utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
             //            実行
                         self.talker.speak(utterance)
                
                
            }
//
        case 1:
            if self.numberForVolumeButton2 == 0 {
            let japaneseText = self.translateTextView.text!
            let utterance = AVSpeechUtterance(string: japaneseText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            self.talker.speak(utterance)
            } else {
                self.numberForVolumeButton2 = 0
                let japaneseText = self.translateLabel.text!
                let utterance = AVSpeechUtterance(string: japaneseText)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                self.talker.speak(utterance)
               
            }
        case 2:
//            音声再生停止
            self.talker.stopSpeaking(at: AVSpeechBoundary.immediate)
           
        default:
            print("nilです")
        }
        return true
    }
    
    
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuItem, forRowAt index: Int) {}
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("メニューが表示されました")
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("メニューが閉じました")
    }
    
    
}


