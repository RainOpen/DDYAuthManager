/** MARK: - DDYAuthManager 2018/10/22
 *  !!!: Author: 豆电雨
 *  !!!: QQ/WX:  634778311
 *  !!!: Github: https://github.com/RainOpen/
 *  !!!: Blog:   https://www.jianshu.com/u/a4bc2516e9e5
 *  MARK: - ViewController.m
 */

#import "ViewController.h"
#import "DDYAuthManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIImage *imgNormal;

@property (nonatomic, strong) UIImage *imgSelect;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imgNormal = [self circleBorderWithColor:[UIColor grayColor] radius:8];
    _imgSelect = [self circleImageWithColor:[UIColor greenColor] radius:8];

    [self registerRemoteNotification];
    [self requestNetAuth];
    
    NSArray *authArray = @[@"麦克风", @"摄像头", @"相册", @"通讯录", @"推送", @"定位", @"联网权限(iOS10+)"];
    for (NSInteger i = 0; i < authArray.count; i++) {
        @autoreleasepool {
            UIButton *button = [self generateButton:i title:authArray[i]];
            if ([[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%ld_auth", button.tag]]) {
                [self performSelectorOnMainThread:@selector(handleClick:) withObject:button waitUntilDone:YES];
            }
        }
    }
}

#pragma mark 联网权限
- (void)requestNetAuth {
    [DDYAuthManager ddy_GetNetAuthWithURL:nil];
}

#pragma mark 远程推送通知 实际要在Appdelegate（可使用分类）
- (void)registerRemoteNotification {
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
}

- (UIButton *)generateButton:(NSInteger)tag title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [button setImage:_imgNormal forState:UIControlStateNormal];
    [button setImage:_imgSelect forState:UIControlStateSelected];
    [button addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTag:tag+100];
    [self.view addSubview:button];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setFrame:CGRectMake(self.view.bounds.size.width/2.-80, tag*45 + 100, 160, 30)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    return button;
}

- (void)handleClick:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:[NSString stringWithFormat:@"%ld_auth", sender.tag]];
    if (sender.tag == 100) {
        [DDYAuthManager ddy_AudioAuthAlertShow:YES success:^{
            sender.selected = YES;
        } fail:^(AVAuthorizationStatus authStatus) { }];
    } else if (sender.tag == 101) {
        if ([DDYAuthManager isCameraAvailable]) {
            [DDYAuthManager ddy_CameraAuthAlertShow:YES success:^{
                sender.selected = YES;
            } fail:^(AVAuthorizationStatus authStatus) { }];
        } else {
            sender.selected = NO;
            [self showAlertWithMessage:@"摄像头不可用"];
        }
    } else if (sender.tag == 102) {
        [DDYAuthManager ddy_AlbumAuthAlertShow:YES success:^{
            sender.selected = YES;
        } fail:^(PHAuthorizationStatus authStatus) { }];
    } else if (sender.tag == 103) {
        [DDYAuthManager ddy_ContactsAuthAlertShow:YES success:^{
            sender.selected = YES;
        } fail:^(DDYContactsAuthStatus authStatus) { }];
    } else if (sender.tag == 104) {
        [DDYAuthManager ddy_PushNotificationAuthAlertShow:YES success:^{
            sender.selected = YES;
        } fail:^{ }];
    } else if (sender.tag == 105) {
        if ([CLLocationManager locationServicesEnabled]) {
            [DDYAuthManager ddy_LocationAuthType:DDYCLLocationTypeAuthorized alertShow:YES success:^{
                sender.selected = YES;
            } fail:^(CLAuthorizationStatus authStatus) {
                sender.selected = NO;
                NSLog(@"定位服务被拒绝");
            }];
        } else {
            sender.selected = NO;
            NSLog(@"定位服务未开启");
        }
        
    } else if (sender.tag == 106) {
        if (@available(iOS 10.0, *)) {
            [DDYAuthManager ddy_NetAuthAlertShow:YES success:^{
                sender.selected = YES;
            } fail:^(CTCellularDataRestrictedState authStatus) { }];
        } else {
            sender.selected = YES;
        }
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 绘制圆形图片
- (UIImage *)circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 绘制圆形框
- (UIImage *)circleBorderWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, radius, radius, radius-1, 0, 2*M_PI, 0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"回到前台");
}

@end
