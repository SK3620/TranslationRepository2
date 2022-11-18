# Uncomment the next line to define a global platform for your project
  platform :ios, '15.0'

target 'TranslationApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TranslationApp
  pod 'RealmSwift', '10.20.0'
  pod 'SVProgressHUD'
  pod 'FSCalendar'
  pod 'CalculateCalendarLogic'
  pod 'ContextMenuSwift'
  pod 'SideMenu', '~> 6.0'
  pod 'Firebase', '8.9.1'
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'CLImageEditor/AllTools','0.2.4'
  pod 'SwiftFormat/CLI'
  pod 'Parchment', '~> 3.0'
   post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
end




