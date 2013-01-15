//
//  KC_iPhoneView.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/26/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCViewController.h"
#import "KC_ShareMessageDelegate.h"
#import "KCVideoProcessingAndShareManager.h"

@class KCVideo;

@interface MainView : KCViewController <KC_ShareMessageDelegate, KCShareDelegate, KamcordDelegate, KCVideoProcessDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

- (id)initWithVideo:(KCVideo *)video;
- (void)dealloc;

@end
