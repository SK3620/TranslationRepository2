//
//  KeyManager.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Foundation
//apikey.plist(APIKeyファイル？）を呼ぶヘルパークラスの作成
//apikeyが複数あるとすれば、その中からkeyを指定してValueを返してくれる。

struct KeyManager {

    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
