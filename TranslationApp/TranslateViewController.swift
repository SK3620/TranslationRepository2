//
//  TranslateViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
import Alamofire
import SVProgressHUD

class TranslateViewController: UIViewController {

    // DeepL APIのレスポンス用構造体
    struct DeepLResult: Codable {
        let translations: [Translation]
        struct Translation: Codable {
            var detected_source_language: String
            var text: String
        }
    }
    
    struct HTTPResponse: Decodable {
        let url: String
    }
    
    @IBOutlet weak var translateTextView: UITextView!
    @IBOutlet weak var translateLabel: UILabel!
    
//    JSONデコード用（？）
    let decoder: JSONDecoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func translateButton(_ sender: Any) {
        if self.translateTextView.text.isEmpty {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "翻訳したい文を入力して下さい")
           
            return
        }else{
        // APIKey.plistに保存したDeepLの認証キーを取得
            SVProgressHUD.show()
                let authKey = KeyManager().getValue(key: "apiKey") as! String
                // APIリクエストするパラメータを作成
                let parameters: [String: String] = [
                    "text": self.translateTextView.text,
                        "target_lang": "EN-US",
                        "auth_key": authKey
                ]
                // ヘッダーを作成
                let headers: HTTPHeaders = [
                        "Content-Type": "application/x-www-form-urlencoded"
                ]
                // DeepL APIを実行
            AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self){ response in
//                         リクエスト成功か判定
                    print("Reponse: \(response)")
                    switch(response.result){
                    case .success(let data):
                        print("url:\(data.url)")
                    case .failure(let error):
                        print("error:\(error)")
                    }
                }
            
        }
    }
}
                    
                    
                    
                    
//                        if case .success = response.result {
//                                do {
//                                        // 結果をデコード
//                                    let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
//                                    // 結果のテキストを取得&画面に反映
//                                    self.translateLabel.text =  result.translations[0].text
//                                    SVProgressHUD.showSuccess(withStatus: "翻訳成功")
//                                    SVProgressHUD.dismiss()
//                                    // 結果をNCMBに保存する処理を呼び出し
//                                    //                                        saveResult()
//                                } catch {
//                                    debugPrint("デコード失敗")
//                                }
//                        } else {
//                            debugPrint("APIリクエストエラー")
//                        }
//                }
//        }
//    }
//}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


