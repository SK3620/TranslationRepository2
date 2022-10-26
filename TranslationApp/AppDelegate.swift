//
//  AppDelegate.swift
//  TranslationApp
//
//  Created by 鈴木健太 on 2022/08/27.
//

import RealmSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // SVProgressHUDをXcode11以上で実行するための環境調整コード
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var config = Realm.Configuration(
            schemaVersion: 1, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 1 {
                    migration.renameProperty(onType: TranslationFolder.className(), from: "result", to: "results")
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 2, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 2 {
                    migration.create(Translation.className(), value: ["id": 0])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 3, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 3 {
                    migration.create(TranslationFolder.className(), value: ["memo": ""])
                }
            }
        )
        config = Realm.Configuration(
            schemaVersion: 4, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 4 {
                    migration.create(Record.className(), value: ["date": ""])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 5, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 5 {
                    migration.renameProperty(onType: Record.className(), from: "date", to: "date3")
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 6, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 6 {
                    migration.create(Record.className(), value: ["date4": Date()])
                }
            }
        )

//        config = Realm.Configuration(
//            schemaVersion: 7, // schemaVersionを2から3に増加。
//            migrationBlock: { migration, oldSchemaVersion in
//                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
//                if oldSchemaVersion < 7 {
//                    migration.create(Record2.className(), value: ["isLiked": false])
//                }
//            })

//        config = Realm.Configuration(
//            schemaVersion: 8, // schemaVersionを2から3に増加。
//            migrationBlock: { migration, oldSchemaVersion in
//                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
//                if oldSchemaVersion < 8 {
//                    migration.create(Record2.className(), value: ["isChecked": 0])
//                }
//            })

        config = Realm.Configuration(
            schemaVersion: 8, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 8 {
                    migration.create(Translation.className(), value: ["isChecked": 0])
                }
            }
        )

//        config = Realm.Configuration(
//            schemaVersion: 9, // schemaVersionを2から3に増加。
//            migrationBlock: { migration, oldSchemaVersion in
//                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
//                if oldSchemaVersion < 9 {
//                    migration.create(Record2.className(), value: ["isDisplayed": 0])
//                }
//            })

        config = Realm.Configuration(
            schemaVersion: 10, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 10 {
                    migration.create(Translation.className(), value: ["isDisplayed": 0])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 11, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 11 {
                    migration.create(Translation.className(), value: ["inputAndResultData": ""])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 12, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 12 {
                    migration.create(Record.className(), value: ["nextReviewDateForSorting": 0])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 12, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 12 {
                    migration.create(Record.className(), value: ["isChecked": 0])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 13, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 13 {
                    migration.create(Record.className(), value: ["inputDate": ""])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 14, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 14 {
                    migration.create(Histroy.className(), value: ["inputAndResultData": ""])
                }
            }
        )

        config = Realm.Configuration(
            schemaVersion: 15, // schemaVersionを2から3に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが3より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < 15 {
                    migration.create(Speak.className(), value: ["id": 0])
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config

        if let APIKEY = KeyManager().getValue(key: "apiKey2") as? String {
            print("DEBUG : \(APIKEY)")
//            print結果 　AIzaSyCqTeoeeM3ONJNt85s6jWzCwt05JA05rPw

//                    GMSServices.provideAPIKey(APIKEY)
//                    GMSPlacesClient.provideAPIKey(APIKEY)
        } // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
