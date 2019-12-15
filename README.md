# [DDYAuthManager](https://github.com/RainOpen/DDYAuthManager)

![DDYAuthManager.png](https://github.com/starainDou/DDYDemoImage/blob/master/DDYAuthManager.png)  ![DDYAuthManager2.png](https://github.com/starainDou/DDYDemoImage/blob/master/DDYAuthManager2.png)

* 各种权限验证(主动申请权限)管理，麦克风权限，相机权限，相册，日历，备忘录，联网权限，推送通知权限，定位权限，语音识别权限等等    
* 各种权限申请(有的不支持二次申请，比如联网权限，在国行版iOS10+一个bundleID只会询问一次)    
* 先鉴定权限，有权限才能进一步执行某些业务    

> # 集成

* CocoaPods方式 

  1.pod 'DDYAuthManager', '~> 1.3.0' 
 
  2.#import <DDYAuthManager/DDYAuthManager.h>

[使用方案](https://github.com/starainDou/DDYAuthorityManager)

* 文件夹拖入工程方式
  
  1.下载工程解压后将'DDYAuthManager'文件夹拖到工程中

  2.#import "DDYAuthManager.h"

> # 配置plist

* 具体信息根据需要自行修改

    ```
     <!-- 权限配置 -->
     <key>NSAppleMusicUsageDescription</key>
     <string>App需要您的同意，才能访问媒体资料库，是否同意？</string>
     <key>NSBluetoothPeripheralUsageDescription</key>
     <string>App需要您的同意，才能访问蓝牙，是否同意？</string>
     <key>NSCalendarsUsageDescription</key>
     <string>App需要您的同意，才能访问日历，是否同意？</string>
     <key>NSCameraUsageDescription</key>
     <string>App需要您的同意，才能使用相机，是否同意？</string>
     <key>NSContactsUsageDescription</key>
     <string>App需要您的同意，才能使用通讯录，是否同意？</string>
     <key>NSHealthShareUsageDescription</key>
     <string>App需要您的同意，才能访问健康分享，是否同意？</string>
     <key>NSHealthUpdateUsageDescription</key>
     <string>App需要您的同意，才能访问健康更新，是否同意？</string>
     <key>NSLocationAlwaysUsageDescription</key>
     <string>App需要您的同意，才能始终访问位置</string>
     <key>NSLocationUsageDescription</key>
     <string>App需要您的同意，才能访问位置，是否同意？</string>
     <key>NSLocationWhenInUseUsageDescription</key>
     <string>App需要您的同意，才能在使用期间访问位置</string>
     <key>NSMicrophoneUsageDescription</key>
     <string>App需要您的同意，才能使用麦克风，是否同意？</string>
     <key>NSMotionUsageDescription</key>
     <string>App需要您的同意，才能访问运动与健身，是否同意？</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>App需要您的同意，才能访问相册，是否同意？</string>
     <key>NSPhotoLibraryAddUsageDescription</key>
     <string>App需要您的同意，才能保存图片到相册，是否同意？</string>
     <key>NSRemindersUsageDescription</key>
     <string>App需要您的同意，才能访问提醒事项，是否同意？</string>
     <key>NSSpeechRecognitionUsageDescription</key>
     <string>App需要您的同意，才能使用语音识别，是否同意？</string>
     <key>NSFaceIDUsageDescription</key>
     <string>App需要您的同意，才能使用Face ID，是否同意？</string>
     <key>NSHomeKitUsageDescription</key>
     <string>App需要您的同意，才能使用HomeKit，是否同意？</string>
     <key>NFCReaderUsageDescription</key>
     <string>App需要您的同意，才能使用NFC，是否同意？</string>
     <key>NSSiriUsageDescription</key>
     <string>App需要您的同意，才能使用Siri，是否同意？</string>
    ```

> # 使用

### 录音(麦克风)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_AudioAuthAlertShow:YES success:^{ } fail:^(AVAuthorizationStatus authStatus) {}];

// 也可以用 [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) { }];请求录音权限
```


### 相机(摄像头)权限

* 鉴定权限和请求权限统一


```
[DDYAuthManager ddy_CameraAuthAlertShow:YES success:^{ } fail:^(AVAuthorizationStatus authStatus) {}];

// 可以先检查摄像头可用性 [DDYAuthManager isCameraAvailable]
```


### 图片(相册)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_AlbumAuthAlertShow:YES success:^{} fail:^(PHAuthorizationStatus authStatus) {}];
```


### 通讯录(联系人)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_ContactsAuthAlertShow:YES success:^{} fail:^(DDYContactsAuthStatus authStatus) {}];
```


### 事件(日历)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_EventAuthAlertShow:YES success:^{} fail:^(EKAuthorizationStatus authStatus) {}];
```


### 备忘录权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_ReminderAuthAlertShow:YES success:^{} fail:^(EKAuthorizationStatus authStatus) {}];
```


### 通知(推送)权限


* 请求权限(注册通知)

```
if (@available(iOS 10.0, *)) {
  UNUserNotificationCenter *currentNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
  UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
  [currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!error) [[UIApplication sharedApplication] registerForRemoteNotifications]; // 注册获得device Token
    });
  }];
} else {
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications]; // 注册获得device Token
}
```

* 鉴定权限

```
[DDYAuthManager ddy_PushNotificationAuthAlertShow:YES success:^{} fail:^{}];
```


### 位置(定位)权限

* 请求权限

```
// CLLocationManager实例必须是全局的变量，否则授权提示弹框可能不会一直显示。
@property (nonatomic, strong) CLLocationManager *locationManager;

if ([CLLocationManager locationServicesEnabled]) {
  _locationManager = [[CLLocationManager alloc] init];
  [_locationManager requestWhenInUseAuthorization];
}
```

* 鉴定权限

```
// 先判断服务是否可用 [CLLocationManager locationServicesEnabled]
[DDYAuthManager ddy_LocationAuthType:DDYCLLocationTypeInUse alertShow:YES success:^{} fail:^(CLAuthorizationStatus authStatus) {}];
```


### 语音识别(语音转文字)权限

* 鉴定权限和请求权限统一

```
if (@available(iOS 10.0, *)) {
  [DDYAuthManager ddy_SpeechAuthAlertShow:YES success:^{} fail:^(SFSpeechRecognizerAuthorizationStatus authStatus) {}]; 
}
```


### 联网权限

* 请求权限


```
// 可以采用主动请求一次网络的形式触发
[DDYAuthManager ddy_GetNetAuthWithURL:nil];
// 如果弹窗不出现，请参照网上方案 [0](https://github.com/Zuikyo/ZIKCellularAuthorization) [1](https://www.jianshu.com/p/244c0774b1fb) [2](https://github.com/ziecho/ZYNetworkAccessibity)
```

* 鉴定权限

```
if (@available(iOS 10.0, *)) {
  [DDYAuthManager ddy_NetAuthAlertShow:YES success:^{} fail:^(CTCellularDataRestrictedState authStatus) {}];
}
```



附：

* 如果pod search DDYAuthManager搜索不到，可以尝试先执行 rm ~/Library/Caches/CocoaPods/search_index.json
* 联网权限不弹窗或者wifi下弹窗拒绝蜂窝网络问题 见https://github.com/Zuikyo/ZIKCellularAuthorization
