#import "NSBundle+DDYAuthManger.h"
#import "DDYAuthManager.h"

@implementation NSBundle (DDYAuthManger)

+ (NSBundle *)ddyAuthManagerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[DDYAuthManager class]];
    return [NSBundle bundleWithURL:[bundle URLForResource:@"DDYAuthManager" withExtension:@"bundle"]];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key {
    return [self ddyLocalizedStringForKey:key value:@""];
}

+ (NSString *)ddyLocalizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"DDYLanguages"];
        if (!language) language = [NSLocale preferredLanguages].firstObject;
        if ([language containsString:@"zh-Hans"]) {
            language = @"zh-Hans";
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle ddyAuthManagerBundle] pathForResource:language ofType:@"lproj"]];
    }
    return [bundle localizedStringForKey:key value:value table:@"DDYAuthManager"];
}

@end
