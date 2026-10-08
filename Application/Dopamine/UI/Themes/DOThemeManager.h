//
//  DOThemeManager.h
//  Dopamine
//
//  Created by tomt000 on 14/02/2024.
//

#import <Foundation/Foundation.h>
#import "DOTheme.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const DOCustomBackgroundDidChangeNotification;

@interface DOThemeManager : NSObject

@property (nonatomic, retain) NSArray<DOTheme*> *themes;

+ (instancetype)sharedInstance;

+ (UIColor*)menuColorWithAlpha:(float)alpha;
- (NSArray*)getAvailableThemeKeys;
- (NSArray*)getAvailableThemeNames;
- (DOTheme*)getThemeForKey:(NSString*)key;
- (DOTheme*)enabledTheme;


#pragma mark - Custom Background

// 当前生效的背景图：优先返回用户自定义背景，未设置时回落到当前主题的背景
- (UIImage*)backgroundImage;
- (BOOL)hasCustomBackground;
- (void)saveCustomBackgroundImage:(UIImage*)image;
- (void)removeCustomBackgroundImage;

@end

NS_ASSUME_NONNULL_END
