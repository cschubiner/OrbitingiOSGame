//
//  KCNotificationScheduler.h
//  cocos2d-ios
//
//  Created by Haitao Mao on 4/1/13.
//
//

#import "Kamcord.h"

@interface KCNotificationScheduler : NSObject

+ (KCNotificationScheduler *) sharedScheduler;
- (void)updateKamcordNotifications:(NSNotification *)notif;
- (void)handleKamcordNotification:(UILocalNotification *)notification;

// Hacky version for Unity because we can't actually pass the notification.
- (void)handleKamcordNotification;

@end
