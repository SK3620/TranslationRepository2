//
//  KeyManager.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Foundation
// apikey.plist(APIKeyファイル）を呼ぶヘルパークラスの作成
// apikeyが複数あるとすれば、その中からkeyを指定してValueを返す。

struct KeyManager {
    // 参考URL http://yuu.1000quu.com/retrieve_the_files_in_the_project
//    APIKey.plistファイルを取得 Bundle.main.pathメソッドで、指定したプロジェクト内のファイルを取得することができる
    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        print("確認 : \(keyFilePath)")
        return NSDictionary(contentsOfFile: keyFilePath)
        //        An initialized dictionary　を返す
        // 指定されたパスのファイルにあるキーと値を使用して、新しく割り当てられた辞書を初期化する。
    }

    // 値を取り出す
    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
