//
//  AppDelegate.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import UIKit
//import GoogleMaps
//import GooglePlaces
import RealmSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // SVProgressHUDをXcode11以上で実行するための環境調整コード
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            schemaVersion: 1, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 1 {
                    migration.renameProperty(onType: TranslationFolder.className(), from: "result", to: "results")
                }
            })
        
        let config1 = Realm.Configuration(
            schemaVersion: 2, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 2 {
                    migration.create(Translation.className(), value: ["id": 0])
                }
            })
        
        let config2 = Realm.Configuration(
            schemaVersion: 3, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 3 {
                    migration.create(TranslationFolder.className(), value: ["memo": ""])
                }
            })
        
        Realm.Configuration.defaultConfiguration = config2
        let realm = try! Realm()
        
        if let APIKEY = KeyManager().getValue(key: "apiKey2") as? String {
            print("DEBUG : \(APIKEY)")
//            print結果 　AIzaSyCqTeoeeM3ONJNt85s6jWzCwt05JA05rPw

//                    GMSServices.provideAPIKey(APIKEY)
//                    GMSPlacesClient.provideAPIKey(APIKEY)
                }    // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

