Pod::Spec.new do |ddyspec|
    ddyspec.name         = 'DDYAuthManager'
    ddyspec.version      = '1.4.0'
    ddyspec.summary      = '各种权限验证(部分带主动申请权限)，麦克风/相机/相册/日历/备忘录/联网/推送通知/定位/语音识别权限等等'
    ddyspec.homepage     = 'https://github.com/RainOpen/DDYAuthManager'
    ddyspec.license      = 'MIT'
    ddyspec.authors      = {'Rain' => '634778311@qq.com'}
    ddyspec.platform     = :ios, '8.0'
    ddyspec.source       = {:git => 'https://github.com/RainOpen/DDYAuthManager.git', :tag => ddyspec.version}
    ddyspec.source_files = 'DDYAuthManager/DDYAuthManager/*.{h,m}'
    ddyspec.resource     = 'DDYAuthManager/DDYAuthManager/DDYAuthManager.bundle'
    ddyspec.requires_arc = true
    ddyspec.frameworks   = "UIKit", "AVFoundation", "AssetsLibrary", "Photos", "AddressBook", "Contacts", "EventKit", "CoreTelephony", "UserNotifications", "CoreLocation", "Speech", "LocalAuthentication", "HealthKit"
end