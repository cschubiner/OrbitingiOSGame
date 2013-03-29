//
//  KCUtil.h
//  cocos2d-ios
//
//  Created by Aditya Rathnam on 3/7/13.
//
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface KCUtil : NSObject

// Returns the reason why MoviePlayer playback finished.
+ (NSString *)getReasonStrForPlaybackFinishNotification:(NSNotification *)notification;

@end
