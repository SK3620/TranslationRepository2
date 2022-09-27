//
//  KeyManager.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Foundation
//apikey.plist(APIKeyファイル？）を呼ぶヘルパークラスの作成
//apikeyが複数あるとすれば、その中からkeyを指定してValueを返す。

struct KeyManager {

//    APIKey.plistファイルを取得
    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        print("確認 : \(keyFilePath)")
        return NSDictionary(contentsOfFile: keyFilePath)
//        An initialized dictionary　を返す
    }

    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
