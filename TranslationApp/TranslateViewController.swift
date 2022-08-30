//
//  TranslateViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import Alamofire
import SVProgressHUD


class TranslateViewController: UIViewController, UITextViewDelegate {

    // DeepL APIのレスポンス用構造体
    struct DeepLResult: Codable {
        let translations: [Translation]
        struct Translation: Codable {
            var detected_source_language: String
            var text: String
        }
    }
    
    
    @IBOutlet weak var translateTextView: UITextView!
    @IBOutlet weak var translateLabel: UILabel!
    
    @IBOutlet weak var languageLabel1: UILabel!
    @IBOutlet weak var languageLabel2: UILabel!
    
//    JSONデコード用（？）
    let decoder: JSONDecoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        languageLabel1.text = "日本語"
        languageLabel2.text = "英語"

//        translateTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func translateButton(_ sender: Any) {
        if self.translateTextView.text == "" {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "文字を入力して下さい")
            return
        } else if self.languageLabel1.text == "日本語" {
       translateJapanese()
        } else {
       translateEnglish()
        }
    }

        @IBAction func changeLanguageButton(_ sender: Any) {
            if self.translateTextView.text == "" {
                return
            } else if languageLabel1.text == "日本語"{
            languageLabel1.text = "英語"
            languageLabel2.text = "日本語"
            translateEnglish()
        } else {
            languageLabel1.text = "日本語"
            languageLabel2.text = "英語"
            translateJapanese()
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
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


