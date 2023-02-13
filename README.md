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
*課題*  
Extensionを利用せずに、カスタムcell上のUIButtonなどをaddTarget()を利用してイベント処理を記述しているため、コードの可読性が低下している。  
*解決策*
カスタムcell上のUIButtonなどは、カスタムcell内にAction接続し、タップ時に呼び出されるデリゲートメソッドを定義する。viewController側からの呼び出し時は、extension HogeViewController: CustomCellButtonTappedDelegate { タップ時の処理 } のように記述することで、コードの可読性が向上する。  



