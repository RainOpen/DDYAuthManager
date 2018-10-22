Pod::Spec.new do |s|
    s.name         = 'DDYAuthManager'
    s.version      = '1.0.0'
    s.summary      = '各种权限验证(部分带主动申请权限)，麦克风/相机/相册/日历/备忘录/联网/推送通知/定位/语音识别权限等等'
    s.homepage     = 'https://github.com/RainOpen/DDYAuthManager'
    s.license      = 'MIT'
    s.authors      = {'Rain' => '634778311@qq.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/RainOpen/DDYAuthManager.git', :tag => s.version}
    s.source_files = 'DDYAuthManager/DDYAuthManager/*.{h,m}'
    s.resource     = 'DDYAuthManager/DDYAuthManager/DDYAuthManager.bundle'
    s.requires_arc = false
end