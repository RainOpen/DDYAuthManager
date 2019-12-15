/// MARK: - DDYAuthManager 2018/10/22
/// !!!: Author: 豆电雨
/// !!!: QQ/WX:  634778311
/// !!!: Github: https://github.com/RainOpen/
/// !!!: Blog:   https://juejin.im/user/57dddcd8128fe10064cadee9
/// MARK: - NSBundle+DDYAuthManger.m

#import "NSBundle+DDYAuthManger.h"
#import "DDYAuthManager.h"

@implementation NSBundle (DDYAuthManger)

+ (instancetype)ddyAuthManagerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[DDYAuthManager class]];
    return [NSBundle bundleWithURL:[bundle URLForResource:@"DDYAuthManager" withExtension:@"bundle"]];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key {
    return [self ddyLocalizedStringForKey:key value:nil];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = nil;
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"DDYLanguages"];
    if (!language) language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"zh"]) {
        language = @"zh-Hans";
    } else {
        language = @"en";
    }
    bundle = [NSBundle bundleWithPath:[[NSBundle ddyAuthManagerBundle] pathForResource:language ofType:@"lproj"]];
    // 如果默认Localizable.strings则nil，这里命名DDYAuthManager.strings
    value =  [bundle localizedStringForKey:key value:value table:@"DDYAuthManager"];
    // (如果拖入工程)可以在[NSBundle mainBundle]查找，如果没有则返回原key
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
