//
//  KeyManager.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import Foundation
// apikey.plist(APIKeyファイル）を呼ぶヘルパークラスの作成
// If there is more than one apikey, specify the key and return the Value.

struct KeyManager {
    // referenceURL http://yuu.1000quu.com/retrieve_the_files_in_the_project
    //    get APIKey.plist file
    // with Bundle.main.path method, you can get specified file in the project
    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        print("確認 : \(keyFilePath)")
        return NSDictionary(contentsOfFile: keyFilePath)
        //        return an initialized dictionary
        // Initializes a newly allocated dictionary using the keys and values found in a file at a given path.
    }

    // retrive apikey
    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
