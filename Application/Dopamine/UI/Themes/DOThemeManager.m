//
//  DOThemeManager.m
//  Dopamine
//
//  Created by tomt000 on 14/02/2024.
//

#import "DOThemeManager.h"
#import "DOPreferenceManager.h"

NSNotificationName const DOCustomBackgroundDidChangeNotification = @"DOCustomBackgroundDidChangeNotification";

@implementation DOThemeManager

+ (instancetype)sharedInstance
{
    static DOThemeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DOThemeManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.themes = [[NSMutableArray alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Themes" ofType:@"plist"];
        NSArray *themes = [NSArray arrayWithContentsOfFile:path];

        for (NSDictionary *theme in themes) {
            DOTheme *newTheme = [[DOTheme alloc] initWithDictionary:theme];
            [((NSMutableArray *)self.themes) addObject:newTheme];
        }

    }
    return self;
}

- (NSArray*)getAvailableThemeKeys
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (DOTheme *theme in _themes) {
        [keys addObject:theme.key];
    }
    return keys;
}

- (NSArray*)getAvailableThemeNames
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (DOTheme *theme in _themes) {
        [names addObject:theme.name];
    }
    return names;
}

- (DOTheme*)getThemeForKey:(NSString*)key
{
    for (DOTheme *theme in _themes) {
        if ([theme.key isEqualToString:key]) {
            return theme;
        }
    }
    return nil;
}

- (DOTheme*)enabledTheme
{
    id value = [[DOPreferenceManager sharedManager] preferenceValueForKey:@"theme"];
    if (!value)
        return self.themes.firstObject;
    return [self getThemeForKey:value] ?: self.themes.firstObject;
}


+ (UIColor*)menuColorWithAlpha:(float)alpha
{
    DOTheme *theme = [[DOThemeManager sharedInstance] enabledTheme];
    
    UIColor *color = theme.actionMenuColor;
    CGFloat red, green, blue, currentAlpha;
    [color getRed:&red green:&green blue:&blue alpha:&currentAlpha];
    return [UIColor colorWithRed:red green:green blue:blue alpha:currentAlpha * alpha];
}

#pragma mark - Custom Background

- (NSString*)customBackgroundPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/customBackground.jpg"];
}

- (BOOL)hasCustomBackground
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self customBackgroundPath]];
}

- (UIImage*)customBackgroundImage
{
    if (![self hasCustomBackground])
        return nil;
    return [UIImage imageWithContentsOfFile:[self customBackgroundPath]];
}

- (UIImage*)backgroundImage
{
    UIImage *custom = [self customBackgroundImage];
    if (custom)
        return custom;
    return [[self enabledTheme] image];
}

- (void)saveCustomBackgroundImage:(UIImage*)image
{
    if (!image)
        return;

    NSData *data = UIImageJPEGRepresentation(image, 0.85);
    if (!data)
        return;

    NSError *error;
    if (![data writeToFile:[self customBackgroundPath] options:NSDataWritingAtomic error:&error])
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DOCustomBackgroundDidChangeNotification object:nil];
    });
}

- (void)removeCustomBackgroundImage
{
    [[NSFileManager defaultManager] removeItemAtPath:[self customBackgroundPath] error:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DOCustomBackgroundDidChangeNotification object:nil];
    });
}

@end
