//
//  KCAnalytics.h
//  cocos2d-ios
//
//  Created by Aditya Rathnam on 12/5/12.
//
//

#import <Foundation/Foundation.h>

@interface KCAnalytics : NSObject<NSURLConnectionDelegate>

typedef enum
{
    KC_ANALYTICS_RECORDING = 0,
    KC_ANALYTICS_VIEWING = 1,
    KC_ANALYTICS_UI_ACTIONS = 2,
    KC_ANALYTICS_SHARING = 3
} KC_ANALYTICS_TYPE;

@property (nonatomic, assign) NSUInteger recordingSampleRate;
@property (nonatomic, assign) NSUInteger viewingSampleRate;
@property (nonatomic, assign) NSUInteger uiActionsSampleRate;
@property (nonatomic, assign) NSUInteger sharingSampleRate;
@property (nonatomic, retain) NSString * deviceIdentifier;
@property (nonatomic, assign) NSUInteger uniqueDeviceHash;
@property (nonatomic, assign) BOOL shouldTrackRecordings;
@property (nonatomic, assign) BOOL shouldTrackViews;
@property (nonatomic, assign) BOOL shouldTrackUIActions;
@property (nonatomic, assign) BOOL shouldTrackShares;
@property (nonatomic, retain) NSDate * lastUpdatedAt;

+ (NSString *)uniqueDeviceStringMD5;
+ (NSString *)uniqueDeviceString;

- (id)init;

- (void)track:(NSString *)eventName
properties:(NSDictionary *)properties
analyticsType:(KC_ANALYTICS_TYPE)analyticsType;

- (void)dealloc;

@end
