//
//  KC_BaseView.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/18/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCVideo.h"
#import "KCVideoProcessingAndShareManager.h"

@interface KC_BaseView : UINavigationController <KCVideoProcessDelegate>

- (id)initMainViewWithFrame:(CGRect)frame
                     isDark:(BOOL)isDark
                      video:(KCVideo *)video;

@property (nonatomic, readonly) BOOL isDark;
@property (nonatomic, readonly) CGRect frame;

@property (nonatomic, retain) KCVideo * latestVideo;
@end
