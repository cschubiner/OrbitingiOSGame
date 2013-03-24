//
//  ZyngaKamcordProtocols.h
//  cocos2d-ios
//
//  Created by Aditya Rathnam on 3/8/13.
//
//

// --------------------------------------------------------
// Kamcord callbacks from the push notification receiver view.
//
@protocol KamcordPushNotificationDelegate <NSObject>

// When the video push notification view appears and disappears
- (void)videoPushNotificationViewDidAppear;
- (void)videoPushNotificationViewDidDisappear;

// When the video in the video push notification view is played and finishes playing.
- (void)videoPushNotificationVideoPlayerDidAppear;
- (void)videoPushNotificationVideoPlayerDidDisappear;

// When the user presses the call to action, all of the parameters
// that were passed in when the
- (void)callToActionButtonWasPressed:(NSDictionary *)params;

@end

