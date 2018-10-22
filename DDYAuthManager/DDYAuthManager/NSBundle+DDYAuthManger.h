#import <Foundation/Foundation.h>

#define DDYAuthManagerI18n(key) [NSBundle ddyLocalizedStringForKey:(key)]

@interface NSBundle (DDYAuthManger)

+ (NSBundle *)ddyAuthManagerBundle;
+ (NSString *)ddyLocalizedStringForKey:(NSString *)key;
+ (NSString *)ddyLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
