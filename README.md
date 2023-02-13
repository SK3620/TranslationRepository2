# Translation Repository  
Using the world's most powerful translation tool DeepL, it enables you to save the text to be translated and the translation results in the created folder.  
# Description  
It is a App for instant English compositon training, which includes a listening feature, a learning record feature, a translation history viewing feature, a favorite registration feature, and a simple SNS feature that allows users to connect with each other.  
# URL / Installation
Compatible with IPhone only (iOS15.0 or later)  
https://apps.apple.com/jp/app/deepl%E7%BF%BB%E8%A8%B3%E4%BF%9D%E5%AD%98/id6443462724  
(You can download the application from this URL.)  
# Requirement  
Apple Swift version 5.7.1 (swiftlang-5.7.1.135.3 clang-1400.0.29.51)  
RealmSwift 10.20.0  
SVProgressHUD  
FSCalendar  
CalculateCalendarLogic  
ContextMenuSwift  
SideMenu ~> 6.0  
Firebase 8.9.1  
Firebase/Analytics   
Firebase/Auth  
Firebase/Firestore  
Firebase/Storage  
FirebaseUI/Storage  
CLImageEditor/AllTools 0.2.4  
SwiftFormat/CLI  
Parchment ~> 3.0  
  
Installed in a terminal using CocoaPods
# Development Environment  
MacOS Monterey version 12.6 MacBook Pro (13-inch, 2019, Two Thunderbolt 3 ports)  
Xcode Version 14.1 (14B47b)  
# Author  
Name: Kenta Suzuki  
Email: (k-n-t1119@ezweb.ne.jp)  
Contact Information: https://tayori.com/form/7c23974951b748bcda08896854f1e7884439eb5c/  
# License  
There is no license for this program.  
(This program is published in a public repository, so GitHub users can view and fork it.)  
# Demo Video  
The first demo video includes the feature to save the sentences to be translated and the translation results, the listening feature and other features.↓  

https://user-images.githubusercontent.com/108386527/216686295-47ff6f71-2e1e-4737-a244-7cdbf178ae4f.mp4　　

The second demo video includes the feature to add words and phrases to user’s favorites.↓  

https://user-images.githubusercontent.com/108386527/216684549-b7db42b4-60ab-450d-acd3-16b9f31f0367.mp4　　

The third demo video includes the study record feature.↓  

https://user-images.githubusercontent.com/108386527/216684356-0ced6358-19c8-4e5b-913f-64859d738a22.mp4　　

The fourth demo video includes the simple SNS feature like Twitter. It has posting, commenting, liking, bookmarking, chatting, reporting, blocking feature, etc.↓  

https://user-images.githubusercontent.com/108386527/216686680-a577e982-f68e-4736-88d7-9c1342074929.mp4　　
# Overall issues, points to be corrected, future measures, etc. (Japanese)  
##### 課題1  
Extensionを利用せずに、カスタムcell上のUIButtonなどをaddTarget()を利用してイベント処理を記述しているため、コードの可読性が低下している。  
##### 解決策  
カスタムcell上のUIButtonなどは、カスタムcell内にAction接続し、タップ時に呼び出されるデリゲートメソッドを定義する。viewController側からの呼び出し時は、extension HogeViewController: CustomCellButtonTappedDelegate { タップ時の処理 } のように記述することで、コードの可読性が向上する。  
##### 課題2  
Segueの多用によって、storyboardが見づらくなる可能性がある。また、iOSアプリ開発の実務経験6年のメンターから、開発現場ではsegueはあまり使用せず、コードのみの画面遷移が基本であるとご指摘をいただいた。    
##### 解決策  
navigationController.pushViewControllerメソッドを利用して、コードのみでの画面遷移を心がける。  
*例 let hogeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Test") as! HogeViewController  
self.navigationController?.pushViewController(hogeViewController, animated: true)*  
##### 課題3  
オブジェクト指向をあまり意識できていないため、コードが肥大化し、可読性が低下している。いいね機能、ブックマーク機能など、タップ時のFirebaseDatabaseへのデータ更新処理を大量のviewControllerに直接記述している。  
##### 解決策  
コードの見通しをよくするために、役割や機能ごとに処理を分ける必要がある。  
FirebaseDatabaseへのデータ更新処理を行う専用の構造体をModelクラスとして作成することで、可読性を向上させる。  
*例  
Struct updateData {  
    static func updateLikes(~){  
              FirebaseDatabaseへのデータ更新処理  
     }  
    static func updateBookMarks(~){  
              FirebaseDatabaseへのデータ更新処理  
     }  
}*  
##### 課題4  
一つのstoryBoardに含まれるviewControllerの数が少し多すぎるため、複数人による開発の際、互いにstoryboardをいじるとコンフリクトが生じる可能性がある。  
##### 解決策4  
複数人で開発を行う場合には、  
・機能ごとにStoryboardを分ける  
・1ViewController,1storyboardに分ける  
・storyboardを使わず、xibを使って開発を行う  
今回は機能ごとにstoryboardを分割したが、一つのstoryBoardに含まれるviewControllerの数が少し多い。もう少し、機能ごとにstoryboardを分割していく必要がある。  
##### 課題5  
Extensionを積極的に活用していないため、コードの可読性が低下している。  
*例 HogeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellButtonTappedDelegate {}*  
##### 解決策5  
Extension HogeViewController: UITableViewDelegate, UITableViewDataSource {}  
Extension HogeViewController: CustomCellButtonTappedDelegate {}  
と記述することでコードの可読性を向上させる。  
##### 課題6  
適切なアクセス修飾子がつけられていないため、開発時に誤って想定外のところでアクセス、呼び出してしまう可能性がある。  
##### 解決策6  
新たにプロパティやメソッドなどの記述する際には、別の場所からアクセスしない限りは、とりあえず全てprivateと記述しておいた方が良い。  
##### 課題7  
開発初期時は、ただ、「機能すれば良い」というスタンスで闇雲にコードを書いていたため、可読性が非常に低い箇所が多数ある。  
##### 解決策7  
保守性を意識したコードを書く必要がある。  
1. 変数名やメソッド名は分かりやすい名前を書く。  
2. コメントはできる限りわかりやすく、無駄なものは書かない。  
3. マジックナンバーは使わない。 変数を利用する。  
4. ネストは深くしすぎない。 深くても２つまで。  
5. インデントをしっかりつける。  
6. プログラムは上から下に処理が流れるように記述する。　など  





 



