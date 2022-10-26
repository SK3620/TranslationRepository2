//
//  TranslateViewController.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Alamofire
import AVFoundation
import ContextMenuSwift
import RealmSwift
import SVProgressHUD
import UIKit

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

    //    フォルダー名を格納
    var folderNameString: String?
    var realm = try! Realm()
    var translationFolderArr = try! Realm().objects(TranslationFolder.self).sorted(byKeyPath: "date", ascending: true)
    //    TabBarControllerインスタンス格納用の変数
    var tabBarController1: TabBarController!

    @IBOutlet var translateTextView1: UITextView!
    @IBOutlet var translateTextView2: UITextView!
    @IBOutlet var label1: UILabel!

    //    日本語、英語切り替え
    @IBOutlet var languageLabel1: UILabel!
    @IBOutlet var languageLabel2: UILabel!

    @IBOutlet var changeLanguageButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var translateButton: UIButton!
    @IBOutlet var selectFolderButton: UIButton!

    @IBOutlet var view1: UIView!
    @IBOutlet var view2: UIView!

    @IBOutlet var copyButton1: UIButton!
    @IBOutlet var copyButton2: UIButton!
    @IBOutlet var volumeButton1: UIButton!
    @IBOutlet var volumeButton2: UIButton!
    @IBOutlet var deleteTextButton1: UIButton!
    @IBOutlet var deleteTextButton2: UIButton!

    var talker = AVSpeechSynthesizer()

    var numberForVolumeButton2: Int = 0

    //    JSONデコード用（？）
    let decoder: JSONDecoder = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Realm確認\(Realm.Configuration.defaultConfiguration.fileURL!)")

        self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"

        self.setButton1(button: [self.selectFolderButton], pointSize: 18, weight: .medium, scale: .medium, systemName: ["square.and.arrow.down"], borderWidth: 1, borderColor: UIColor.systemBlue.cgColor, cornerRadius: 10)

        let buttonArr: [UIButton]! = [copyButton1, copyButton2, volumeButton1, volumeButton2, deleteTextButton1, deleteTextButton2]
        let systemNameArr = ["doc.on.doc", "doc.on.doc", "volume.3", "volume.3", "delete.left", "delete.left"]
        self.setButton1(button: buttonArr, pointSize: 20, weight: .regular, scale: .small, systemName: systemNameArr, borderWidth: nil, borderColor: nil, cornerRadius: nil)

        self.setButton2(button: [self.changeLanguageButton, self.saveButton, self.translateButton], borderColor: UIColor.systemBlue.cgColor, borderWidth: 1, cornerRadius: 10)
        self.saveButton.isEnabled = false
        self.saveButton.isHidden = true
        self.saveButton.titleLabel?.numberOfLines = 1
        // ボタンの横幅に応じてフォントサイズを自動調整する設定
        self.saveButton.titleLabel?.adjustsFontSizeToFitWidth = true

        self.setTranslateTextViewAndView()
        self.translateTextView1.delegate = self

        self.languageLabel1.text = "Japanese"
        self.languageLabel2.text = "English"

        if let folderNameString = folderNameString {
            self.saveButton.isHidden = false
            self.saveButton.isEnabled = true
            self.saveButton.setTitle("\(folderNameString)　へ保存する", for: .normal)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // キーボードに完了のツールバーを作成
        self.setDoneTooBar()
    }

    //    UIButtonの設定
    func setButton1(button: [UIButton], pointSize: CGFloat, weight: UIImage.SymbolWeight, scale: UIImage.SymbolScale, systemName: [String], borderWidth: CGFloat?, borderColor: CGColor?, cornerRadius: CGFloat?) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)

        for i in 0 ... button.count - 1 {
            let systemIcon = UIImage(systemName: systemName[i], withConfiguration: config)
            button[i].setImage(systemIcon, for: .normal)
            if borderWidth != nil {
                button[i].layer.borderWidth = borderWidth!
                button[i].layer.borderColor = borderColor!
                button[i].layer.cornerRadius = cornerRadius!
            }
        }
    }

    //    UIbuttonの設定
    func setButton2(button: [UIButton], borderColor: CGColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        for i in 0 ... button.count - 1 {
            button[i].layer.borderColor = borderColor
            button[i].layer.borderWidth = borderWidth
            button[i].layer.cornerRadius = cornerRadius
        }
    }

    //　　textViewとViewの設定
    func setTranslateTextViewAndView() {
        let color = UIColor.systemGray4.cgColor
        self.translateTextView1.layer.borderColor = color
        self.translateTextView1.layer.borderWidth = 2
        self.translateTextView1.clipsToBounds = true

        self.translateTextView2.layer.borderWidth = 2
        self.translateTextView2.layer.borderColor = color
        self.translateTextView2.clipsToBounds = true

        self.view1.layer.borderWidth = 2
        self.view1.layer.borderColor = color

        self.view2.layer.borderWidth = 2
        self.view2.layer.borderColor = color
    }

    func setDoneTooBar() {
        let doneToolbar = UIToolbar()
        doneToolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
        // 左側のBarButtonItemはflexibleSpace。これがないと右に寄らない。flexibleSpaceはBlank space to add between other items
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(self.doneButtonTaped))
        //        The items displayed on the toolbar.
        doneToolbar.items = [spacer, doneButton]
        let someArr = [translateTextView1, translateTextView2]
        for someNumber in someArr {
            //            // textViewのキーボードにツールバーを設定
            someNumber!.inputAccessoryView = doneToolbar
        }
    }

    @objc func doneButtonTaped(sender _: UIButton) {
        self.translateTextView1.endEditing(true)
        self.translateTextView2.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_: Bool) {
        super.viewDidAppear(true)

//        navigationBarのタイトルを設定
        self.tabBarController1.setBarButtonItem0()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

        if let folderNameString = folderNameString {
            let translationFolderArr2 = self.realm.objects(TranslationFolder.self)
            var FolderNameArr = [String]()
            if translationFolderArr2.count == 0 {
                self.saveButton.isEnabled = false
                self.saveButton.isHidden = true
            } else {
                for number in 0 ... translationFolderArr2.count - 1 {
                    FolderNameArr.append(translationFolderArr2[number].folderName)
                }
            }

            if FolderNameArr.contains(folderNameString) {
                self.saveButton.setTitle("保存先▷\(folderNameString)", for: .normal)
                self.saveButton.isHidden = false
                self.saveButton.isEnabled = true
            } else {
                self.saveButton.isEnabled = false
                self.saveButton.isHidden = true
            }
        }
    }

    @IBAction func translateButton(_: Any) {
        if self.translateTextView1.text == "" {
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "赤枠内にテキストを入力して、翻訳して下さい")
            self.translateTextView1.layer.borderColor = UIColor.red.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.changeIcon)
            return
        } else if self.languageLabel1.text == "Japanese" {
            self.translateJapanese()
        } else {
            self.translateEnglish()
        }
    }

    @IBAction func changeLanguageButton(_: Any) {
        if self.languageLabel1.text == "Japanese" {
            self.languageLabel1.text = "English"
            self.languageLabel2.text = "Japanese"

        } else {
            self.languageLabel1.text = "Japanese"
            self.languageLabel2.text = "English"
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == self.translateTextView1 {
            if self.translateTextView1.text != "" {
                self.label1.text = ""
            } else {
                self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
            }

            if self.languageLabel1.text == "Japanese" {
                self.translateJapanese()
            } else {
                self.translateEnglish()
            }
        }
    }

    func translateEnglish() {
        let authKey1 = KeyManager().getValue(key: "apiKey") as! String
        print("DEBUG : \(authKey1)")
        //            print結果　914cbb6c-40d6-0314-6e30-5fbd278de0ac:fx

        //            前後のスペースと改行を削除
        let authKey = authKey1.trimmingCharacters(in: .newlines)

        // APIリクエストするパラメータを作成　リクエストするために必要な情報を定義　リクエスト成功時に、翻訳結果が返される
        let parameters: [String: String] = [
            "text": translateTextView1.text,
            "auth_key": authKey,
            "source_lang": "EN",
            "target_lang": "JA",
        ]

        // ヘッダーを作成
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        // DeepL APIリクエストを実行
        //        AF = Almofireのこと
        //        Almofireはapi情報を取得するための便利なライブラリ　通常はswift側で用意されているURLSessionを使う。
        //        requestメソッドでAPIを呼ぶ
        AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in

            if case .success = response.result {
                do {
                    // 結果をデコード
                    //                    一般的に、アプリがAPIサーバーと通信する場合、データはJSON形式でやりとりすることが多いかと思います。Foundationフレームワークの JSONEncoder クラスを使用すると、Swiftの値をJSONに変換することができ、JSONDecoder クラスはJSONをSwiftの値にデコードすることができます
                    let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
                    // 結果のテキストを取得&画面に反映
                    self.translateTextView2.text = result.translations[0].text

                } catch {
                    debugPrint("デコード失敗")
                }
            } else {
                debugPrint("APIリクエストエラー")
            }
        }
    }

    func translateJapanese() {
        // APIKey.plistに保存したDeepLの認証キーを取得
        let authKey1 = KeyManager().getValue(key: "apiKey") as! String
        print("DEBUG : \(authKey1)")
        //            print結果　914cbb6c-40d6-0314-6e30-5fbd278de0ac:fx

        //            前後のスペースと改行を削除
        let authKey = authKey1.trimmingCharacters(in: .newlines)

        // APIリクエストするパラメータを作成
        let parameters: [String: String] = [
            "text": translateTextView1.text,
            "auth_key": authKey,
            "source_lang": "JA",
            "target_lang": "EN",
        ]

        // ヘッダーを作成
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        // DeepL APIを実行
        AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
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
            // }
            if case .success = response.result {
                do {
                    // 結果をデコード
                    let result = try self.decoder.decode(DeepLResult.self, from: response.data!)
                    // 結果のテキストを取得&画面に反映
                    self.translateTextView2.text = result.translations[0].text

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

    @IBAction func SaveButton(_: Any) {
        if self.translateTextView2.text != "", self.translateTextView2.text != "" {
            if let folderNameString = folderNameString {
                SVProgressHUD.show()
                let translateTextView1Text = self.translateTextView1.text
                let translateTextView2Text = self.translateTextView2.text

                let predict = NSPredicate(format: "folderName == %@", folderNameString)
                self.translationFolderArr = self.realm.objects(TranslationFolder.self).filter(predict)

                let translation = Translation()
                translation.inputData = translateTextView1Text!
                translation.resultData = translateTextView2Text! + "\n" + "メモ : "
                translation.inputAndResultData = translation.inputData + translation.resultData
                let translationArr = self.realm.objects(Translation.self)
                if translationArr.count != 0 {
                    translation.id = translationArr.max(ofProperty: "id")! + 1
                }

                try! self.realm.write {
                    translationFolderArr.first!.results.append(translation)
                }

//                    HistoryViewContoller(翻訳履歴画面）用にHistoryモデルクラスへ保存
                let history = Histroy()

                let historyArr = self.realm.objects(Histroy.self)
                if historyArr.count != 0 {
                    history.id = historyArr.max(ofProperty: "id")! + 1
                }

                try! self.realm.write {
                    history.inputData = translateTextView1Text!
                    history.resultData = translateTextView2Text!
                    history.date = Date()
                    history.inputAndResultData = translateTextView1Text! + translateTextView2Text!
                    self.realm.add(history)
                }

                SVProgressHUD.showSuccess(withStatus: "'\(folderNameString)' へ保存しました")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: self.showDismiss)

                if self.translateTextView1.layer.borderWidth == 2 {
                    self.translateTextView1.layer.borderWidth = 2
                    self.translateTextView1.layer.borderColor = UIColor.systemGray4.cgColor
                }

                if self.translateTextView2.layer.borderWidth == 2 {
                    self.translateTextView2.layer.borderWidth = 2
                    self.translateTextView2.layer.borderColor = UIColor.systemGray4.cgColor
                }
            }

        } else if self.translateTextView1.text == "", self.translateTextView2.text == "" {
            self.error1()
            self.error2()
        } else if self.translateTextView1.text == "" {
            self.error1()
            SVProgressHUD.show()
            SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力してください")
        } else {
            self.error2()
        }
    }

    func showDismiss() {
        SVProgressHUD.dismiss()
    }

    func error1() {
        let borderColor1 = UIColor.red.cgColor
        self.translateTextView1.layer.borderWidth = 2
        self.translateTextView1.layer.borderColor = borderColor1

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.changeIcon)
    }

    func error2() {
        SVProgressHUD.show()
        let borderColor1 = UIColor.red.cgColor
        self.translateTextView2.layer.borderWidth = 2
        self.translateTextView2.layer.borderColor = borderColor1
        SVProgressHUD.showError(withStatus: "保存失敗\n赤枠内にテキストを入力してください")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.changeIcon)
    }

    func changeIcon() {
        let borderColor1 = UIColor.systemGray4.cgColor
        self.translateTextView1.layer.borderWidth = 2
        self.translateTextView2.layer.borderColor = borderColor1

        self.translateTextView2.layer.borderWidth = 2
        self.translateTextView2.layer.borderColor = borderColor1

        SVProgressHUD.dismiss()
    }

    @IBAction func deleteButton1(_: Any) {
        self.translateTextView1.text = ""
        self.label1.text = "ドラマや映画のフレーズや単語、自英作文などを入力して作成したフォルダーに保存しよう！"
    }

    @IBAction func deleteButton2(_: Any) {
        self.translateTextView2.text = ""
    }

    @IBAction func selectFolderButton(_: Any) {
        let selectFolderForTranslateViewContoller = storyboard?.instantiateViewController(withIdentifier: "FolderList") as! SelectFolderForTranslateViewContoller

        if let sheet = selectFolderForTranslateViewContoller.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        selectFolderForTranslateViewContoller.translateViewController = self
        present(selectFolderForTranslateViewContoller, animated: true, completion: nil)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

    func setStringForButton2() {
        self.tabBarController1.setBarButtonItem0()
        self.tabBarController1.navigationController?.setNavigationBarHidden(false, animated: false)

        if let folderNameString = folderNameString {
            let translationFolderArr2 = self.realm.objects(TranslationFolder.self)
            var FolderNameArr = [String]()
            if translationFolderArr2.count == 0 {
                self.saveButton.isEnabled = false
                self.saveButton.isHidden = true
                return
            } else {
                for number in 0 ... translationFolderArr2.count - 1 {
                    FolderNameArr.append(translationFolderArr2[number].folderName)
                }
            }

            if FolderNameArr.contains(folderNameString) {
                self.saveButton.setTitle("保存先▷\(folderNameString)", for: .normal)
                self.saveButton.isHidden = false
                self.saveButton.isEnabled = true

            } else {
                self.saveButton.isEnabled = false
                self.saveButton.isHidden = true
            }
        }
    }

    @IBAction func copyButton1(_: Any) {
        self.copyTextView(textView: self.translateTextView1, button: self.copyButton1)
    }

    @IBAction func copyButton2(_: Any) {
        self.copyTextView(textView: self.translateTextView2, button: self.copyButton2)
    }

    func copyTextView(textView: UITextView, button: UIButton) {
        UIPasteboard.general.string = textView.text
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        button.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.chageCopyIcon)
    }

    func chageCopyIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .small)
        self.copyButton1.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: config), for: .normal)
        self.copyButton2.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: config), for: .normal)
    }

    //　音声再生
    @IBAction func volumeButton1(_: Any) {
        self.speak(textView: self.translateTextView1)
        self.numberForVolumeButton2 = 0
    }

//    音声再生
    @IBAction func volumeButton2(_: Any) {
        self.speak(textView: self.translateTextView2)
        self.numberForVolumeButton2 = 1
    }

    func speak(textView: UITextView) {
        let english = ContextMenuItemWithImage(title: "英語", image: UIImage())
        let japanese = ContextMenuItemWithImage(title: "日本語", image: UIImage())
        let stop = ContextMenuItemWithImage(title: "停止", image: UIImage())

        CM.items = [english, japanese, stop]
        CM.showMenu(viewTargeted: textView, delegate: self, animated: true)
    }
}

extension TranslateViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt index: Int) -> Bool {
        switch index {
        case 0:
            if self.numberForVolumeButton2 == 0 {
                let englishText = self.translateTextView1.text!
//                話す内容をセット
                let utterance = AVSpeechUtterance(string: englishText)
                //            言語を英語に設定
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                //            実行
                self.talker.speak(utterance)
            } else {
                self.numberForVolumeButton2 = 0
                let englishText = self.translateTextView2.text!
                let utterance = AVSpeechUtterance(string: englishText)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                self.talker.speak(utterance)
            }
//
        case 1:
            if self.numberForVolumeButton2 == 0 {
                let japaneseText = self.translateTextView1.text!
                let utterance = AVSpeechUtterance(string: japaneseText)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                self.talker.speak(utterance)
            } else {
                self.numberForVolumeButton2 = 0
                let japaneseText = self.translateTextView2.text!
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

    func contextMenuDidDeselect(_: ContextMenu, cell _: ContextMenuCell, targetedView _: UIView, didSelect _: ContextMenuItem, forRowAt _: Int) {}

    func contextMenuDidAppear(_: ContextMenu) {
        print("メニューが表示されました")
    }

    func contextMenuDidDisappear(_: ContextMenu) {
        print("メニューが閉じました")
    }
}
