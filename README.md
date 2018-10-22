# DDYAuthManager

各种权限验证(主动申请权限)管理，麦克风权限，相机权限，相册，日历，备忘录，联网权限，推送通知权限，定位权限，语音识别权限等等

> ### 录音(麦克风)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_AudioAuthAlertShow:YES success:^{ } fail:^(AVAuthorizationStatus authStatus) {}];

// 也可以用 [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) { }];请求录音权限
```

<br>
> ### 相机(摄像头)权限

* 鉴定权限和请求权限统一


```
[DDYAuthManager ddy_CameraAuthAlertShow:YES success:^{ } fail:^(AVAuthorizationStatus authStatus) {}];

// 可以先检查摄像头可用性 [DDYAuthManager isCameraAvailable]
```

<br>
> ### 图片(相册)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_AlbumAuthAlertShow:YES success:^{} fail:^(PHAuthorizationStatus authStatus) {}];
```

<br>
> ### 通讯录(联系人)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_ContactsAuthAlertShow:YES success:^{} fail:^(DDYContactsAuthStatus authStatus) {}];
```

<br>
> ### 事件(日历)权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_EventAuthAlertShow:YES success:^{} fail:^(EKAuthorizationStatus authStatus) {}];
```

<br>
> ### 备忘录权限

* 鉴定权限和请求权限统一

```
[DDYAuthManager ddy_ReminderAuthAlertShow:YES success:^{} fail:^(EKAuthorizationStatus authStatus) {}];
``
<br>
> ### 通知(推送)权限

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

<br>
> ### 位置(定位)权限

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

<br>
> ### 语音识别(语音转文字)权限

* 鉴定权限和请求权限统一

```
if (@available(iOS 10.0, *)) {
  [DDYAuthManager ddy_SpeechAuthAlertShow:YES success:^{} fail:^(SFSpeechRecognizerAuthorizationStatus authStatus) {}]; 
}
```

<br>
> ### 联网权限

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


# 
