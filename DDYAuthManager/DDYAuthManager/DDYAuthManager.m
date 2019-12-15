/// MARK: - DDYAuthManager 2018/10/22
/// !!!: Author: 豆电雨
/// !!!: QQ/WX:  634778311
/// !!!: Github: https://github.com/RainOpen/
/// !!!: Blog:   https://juejin.im/user/57dddcd8128fe10064cadee9
/// MARK: - DDYAuthManager.m

#import "DDYAuthManager.h"
#import "NSBundle+DDYAuthManger.h"

@interface DDYAuthManager ()<CLLocationManagerDelegate>

/// CLLocationManager实例必须是全局的变量，否则授权提示弹框可能不会一直显示。
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) DDYCLLocationType locationType;
@property (nonatomic, assign) BOOL locationShow;
@property (nonatomic, copy) void (^locationSuccessBlock)(void);
@property (nonatomic, copy) void (^locationFailureBlock)(CLAuthorizationStatus);

@end

@implementation DDYAuthManager

+ (instancetype)shareInstance {
    static DDYAuthManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

// [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) { }];
// MARK: - 麦克风权限
+ (void)ddy_AudioAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(AVAuthorizationStatus))fail {
    void (^handleResult)(BOOL, AVAuthorizationStatus) = ^(BOOL isAuthorized, AVAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        };
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthMicrophone"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(granted, granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
            });
        }];
    } else  {
        handleResult(authStatus == AVAuthorizationStatusAuthorized, authStatus);
    }
}

// MARK: - 摄像头(相机)权限
+ (void)ddy_CameraAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(AVAuthorizationStatus))fail {
    void (^handleResult)(BOOL, AVAuthorizationStatus) = ^(BOOL isAuthorized, AVAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthCamera"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(granted, granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
            });
        }];
    } else  {
        handleResult(authStatus == AVAuthorizationStatusAuthorized, authStatus);
    }
}

// MARK: 判断设备摄像头是否可用
+ (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// MARK: 前面的摄像头是否可用
+ (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// MARK: 后面的摄像头是否可用
+ (BOOL)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// MARK: - 相册使用权限(iOS 8+)
+ (void)ddy_AlbumAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(PHAuthorizationStatus))fail {
    void (^handleResult)(BOOL, PHAuthorizationStatus) = ^(BOOL isAuthorized, PHAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthAlbum"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(status == PHAuthorizationStatusAuthorized, status);
            });
        }];
    } else {
        handleResult(authStatus == PHAuthorizationStatusAuthorized, authStatus);
    }
}

// MARK: - 通讯录权限
+ (void)ddy_ContactsAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(DDYContactsAuthStatus))fail {
    void (^handleResult)(BOOL, DDYContactsAuthStatus) = ^(BOOL isAuthorized, DDYContactsAuthStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthContacts"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authStatus == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handleResult(granted, granted ? DDYContactsAuthStatusAuthorized : DDYContactsAuthStatusDenied);
                });
            }];
        } else if (authStatus == CNAuthorizationStatusRestricted) {
            handleResult(NO, DDYContactsAuthStatusRestricted);
        } else if (authStatus == CNAuthorizationStatusDenied) {
            handleResult(NO, DDYContactsAuthStatusDenied);
        } else if (authStatus == CNAuthorizationStatusAuthorized) {
            handleResult(YES, DDYContactsAuthStatusAuthorized);
        }
    } else {
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        if (authStatus == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handleResult(granted, granted ? DDYContactsAuthStatusAuthorized : DDYContactsAuthStatusDenied);
                });
            });
        } else if (authStatus == kABAuthorizationStatusRestricted) {
            handleResult(NO, DDYContactsAuthStatusRestricted);
        } else if (authStatus == kABAuthorizationStatusDenied) {
            handleResult(NO, DDYContactsAuthStatusDenied);
        } else if (authStatus == kABAuthorizationStatusAuthorized) {
            handleResult(YES, DDYContactsAuthStatusAuthorized);
        }
    }
}

// MARK: - 日历权限
+ (void)ddy_EventAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(EKAuthorizationStatus))fail {
    void (^handleResult)(BOOL, EKAuthorizationStatus) = ^(BOOL isAuthorized, EKAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthCalendars"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (authStatus == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(granted, granted ? EKAuthorizationStatusAuthorized : EKAuthorizationStatusDenied);
            });
        }];
    } else  {
        handleResult(authStatus == EKAuthorizationStatusAuthorized, authStatus);
    }
}

// MARK: - 备忘录权限
+ (void)ddy_ReminderAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(EKAuthorizationStatus))fail {
    void (^handleResult)(BOOL, EKAuthorizationStatus) = ^(BOOL isAuthorized, EKAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthReminders"]];
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
    };
    
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    if (authStatus == EKAuthorizationStatusNotDetermined) {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(granted, granted ? EKAuthorizationStatusAuthorized : EKAuthorizationStatusDenied);
            });
        }];
    } else  {
        handleResult(authStatus == EKAuthorizationStatusAuthorized, authStatus);
    }
}

/** 关于APP首次安装(一旦用户选择后即使卸载重装也不会再弹窗)联网权限弹窗，无法得知用户是否点击允许或不允许(苹果没有给出api),所以常规按以下流程自行判断
 *  1.用keychain记录是否是首次安装(和弹窗一致)，若是首次安装则启动APP后进入特定界面(如引导页),如果不是那么严格忽略该步骤。
 *  2.用 -checkNetworkConnectWhenAirplaneModeOrNoWlanCellular 判断是否特殊情况(完全无网络时首次启动APP，不会联网权限弹窗)。
 *  3.若第二步通过(如果不考虑极端情况直接该步骤)，用户有以太网进入则发送网络请求(最好head请求，省流量且更快速)，如果是首次联网则可能弹窗。
 不确定是否弹窗(2G网络，弱网，飞行模式或同时无wifi和蜂窝网络，只wifi但wifi并没有以太网等等情况不弹窗)，也不确定如果弹窗用户的选择。
 *  4.进入真正页面,用Reachability(或AFNetworkReachabilityStatusNotReachable或RealReachability)判断网络状态。
 *  5.用 -fetchSSIDInfo 或 -fetchMobileInfo 判断确实存在能使得弹窗的网络。
 *  6.用CTCellularData获取状态，此时粗略得到用户是否授权联网权限。
 */
// MARK: - 用网络请求方式主动获取一次权限
+ (void)ddy_GetNetAuthWithURL:(NSURL *)url {
    // 为了快速请求且流量最小化，这里用Head请求，只获取响应头
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:(url ? url : [NSURL URLWithString:@"https://www.baidu.com"])];
    [request setHTTPMethod:@"HEAD"];
    NSURLSessionDataTask * dataTask =  [session dataTaskWithRequest:request completionHandler:^(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        // 拿到响应头信息
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        // 解析拿到的响应数据
        NSLog(@"DDYAuthManager request baidu:\n%s_%@\n%@",__FUNCTION__, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], res.allHeaderFields);
    }];
    [dataTask resume];
}

// MARK: - 联网权限 iOS 10+
/**
 // 网络权限更改回调,如果不想每次改变都回调那记得置nil
 cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
 dispatch_async(dispatch_get_main_queue(), ^{
 if (state == kCTCellularDataNotRestricted) {
 if (authState != state) handleResult(YES, state);
 } else {
 if (authState != state) handleResult(NO, state);
 if (show && authState != state) handleResult(NO, authState);
 }
 });
 };
 */
+ (void)ddy_NetAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(CTCellularDataRestrictedState))fail {
    // CTCellularData在iOS9之前是私有类，但联网权限设置是iOS10开始的
    if (@available(iOS 10.0, *)) {
        void (^handleResult)(BOOL, CTCellularDataRestrictedState) = ^(BOOL isAuthorized, CTCellularDataRestrictedState authStatus) {
            if (isAuthorized && success) {
                success();
            }
            if (!isAuthorized && show) {
                [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthNetwork"]];
            }
            if (!isAuthorized && fail) {
                fail(authStatus);
            }
        };
        CTCellularData *cellularData = [[CTCellularData alloc] init];
        CTCellularDataRestrictedState authState = cellularData.restrictedState;
        if (authState == kCTCellularDataNotRestricted) {
            handleResult(YES, authState);
        } else if (authState == kCTCellularDataRestricted) {
            handleResult(NO, authState);
        } else {
            // CTCellularData刚实例化对象时可能kCTCellularDataRestrictedStateUnknown，所以延迟一下
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CTCellularDataRestrictedState authState2 = cellularData.restrictedState;
                if (authState2 == kCTCellularDataNotRestricted) {
                    handleResult(YES, authState2);
                } else if (authState == kCTCellularDataRestricted) {
                    handleResult(NO, authState2);
                } else {
                    handleResult(NO, authState2);
                }
            });
        }
    }
}

// MARK: - 推送通知权限 需要在打开 target -> Capabilities —> Push Notifications
+ (void)ddy_PushNotificationAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(void))fail {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *notiCenter = [UNUserNotificationCenter currentNotificationCenter];
        [notiCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                [notiCenter requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted && success) {
                            success();
                        }
                        if (!granted && show) {
                            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthNotifications"]];
                        }
                        if (!granted && fail) {
                            fail();
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (settings.authorizationStatus == UNAuthorizationStatusAuthorized && success) {
                        success();
                    }
                    if (settings.authorizationStatus != UNAuthorizationStatusAuthorized && fail) {
                        fail();
                    }
                    if (show && settings.authorizationStatus == UNAuthorizationStatusDenied) {
                        [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthNotifications"]];
                    }
                });
            }
        }];
    } else {
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        // UIUserNotificationTypeNone 收到通知不呈现UI，可能无权限也可能还未询问权限
        if (settings.types != UIUserNotificationTypeNone && success) success();
        if (settings.types == UIUserNotificationTypeNone && fail) fail();
        if (show && settings.types == UIUserNotificationTypeNone) [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthNotifications"]];
    }
}

// MARK: - 定位权限
+ (void)ddy_LocationAuthType:(DDYCLLocationType)type alertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(CLAuthorizationStatus))fail{

    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];

    if ([CLLocationManager locationServicesEnabled]) {
        if (authStatus == kCLAuthorizationStatusNotDetermined || authStatus == kCLAuthorizationStatusRestricted) {
            [DDYAuthManager shareInstance].locationManager = [[CLLocationManager alloc] init];
            [DDYAuthManager shareInstance].locationManager.delegate = [DDYAuthManager shareInstance];
            [[DDYAuthManager shareInstance].locationManager requestAlwaysAuthorization];
            [[DDYAuthManager shareInstance].locationManager requestWhenInUseAuthorization];
            [[DDYAuthManager shareInstance].locationManager startUpdatingLocation];
            [DDYAuthManager shareInstance].locationType = type;
            [DDYAuthManager shareInstance].locationShow = show;
            [DDYAuthManager shareInstance].locationSuccessBlock = success;
            [DDYAuthManager shareInstance].locationFailureBlock = fail;
        } else if (authStatus == kCLAuthorizationStatusDenied) {
            if (show) {
                [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthLocation"]];
            }
            if (fail) {
                fail(authStatus);
            }
        } else {
            if (authStatus == kCLAuthorizationStatusAuthorizedAlways && type == DDYCLLocationTypeAlways) {
                if (success) {
                    success();
                }
            } else if (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse && type == DDYCLLocationTypeInUse) {
                if (success) {
                    success();
                }
            } else if (type == DDYCLLocationTypeAuthorized) {
                if (success) {
                    success();
                }
            } else {
                if (show) {
                    [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthLocation"]];
                }
                if (fail) {
                    fail(authStatus);
                }
            }
        }
    } else {
        NSLog(@"Location Services 未开启 %d", authStatus);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [DDYAuthManager ddy_LocationAuthType:[DDYAuthManager shareInstance].locationType
                                   alertShow:[DDYAuthManager shareInstance].locationShow
                                     success:[DDYAuthManager shareInstance].locationSuccessBlock
                                        fail:[DDYAuthManager shareInstance].locationFailureBlock];
    });
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [DDYAuthManager ddy_LocationAuthType:[DDYAuthManager shareInstance].locationType
                                   alertShow:[DDYAuthManager shareInstance].locationShow
                                     success:[DDYAuthManager shareInstance].locationSuccessBlock
                                        fail:[DDYAuthManager shareInstance].locationFailureBlock];
    });
}

// MARK: - 语音识别(转文字)权限
+ (void)ddy_SpeechAuthAlertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(SFSpeechRecognizerAuthorizationStatus))fail {
    void (^handleResult)(BOOL, SFSpeechRecognizerAuthorizationStatus) = ^(BOOL isAuthorized, SFSpeechRecognizerAuthorizationStatus authStatus) {
        if (isAuthorized && success) {
            success();
        }
        if (!isAuthorized && fail) {
            fail(authStatus);
        }
        if (!isAuthorized && show) {
            [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthSpeech"]];
        }
    };
    SFSpeechRecognizerAuthorizationStatus authStatus = [SFSpeechRecognizer authorizationStatus];
    if (authStatus == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handleResult(status == SFSpeechRecognizerAuthorizationStatusAuthorized, status);
            });
        }];
    } else {
        handleResult(authStatus == SFSpeechRecognizerAuthorizationStatusAuthorized, authStatus);
    }
}

// MARK: - 健康数据权限
+ (void)ddy_HealthAuth:(HKQuantityTypeIdentifier)type alertShow:(BOOL)show success:(void (^)(void))success fail:(void (^)(HKAuthorizationStatus))fail {
    if ([HKHealthStore isHealthDataAvailable]) {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:type];
        if (quantityType) {
            HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:quantityType];
            if (authStatus == HKAuthorizationStatusSharingAuthorized && success) {
                success();
            }
            if (authStatus != HKAuthorizationStatusSharingAuthorized && fail) {
                fail(authStatus);
            }
            if (authStatus != HKAuthorizationStatusSharingAuthorized && show) {
                [self showAlertWithAuthInfo:[self i18n:@"DDYNoAuthHealth"]];
            }
        }
    } else {
        NSLog(@"健康数据不可用");
    }
}

// MARK: - 私有方法
// MARK: 默认无权限提示
+ (void)showAlertWithAuthInfo:(NSString *)authInfo {
    NSString *message = [authInfo stringByReplacingOccurrencesOfString:@"%@" withString:[self getAPPName]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[self i18n:@"DDYNoAuthCancel"] style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:[self i18n:@"DDYNoAuthConfirm"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }]];
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

// MARK: 获取App名
+ (NSString *)getAPPName {
    if ([DDYAuthManager shareInstance].appName) {
        return [DDYAuthManager shareInstance].appName;
    } else {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        // CFShow((__bridge CFTypeRef)(infoDictionary));
        NSString *bundleDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *bundleName = [infoDictionary objectForKey:@"CFBundleName"];
        return bundleDisplayName ?: (bundleName ?: @"App");
    }
}

// MARK: 国际化支持
+ (NSString *)i18n:(NSString *)str {
    return [NSBundle ddyAuthManagerLocalizedStringForKey:str];
}

@end
