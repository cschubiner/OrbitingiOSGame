//
//  KC_BaseView.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/18/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCVideoProcessingAndShareManager.h"
#import "VideoTableViewController.h"
#import "KCUiAssetMap.h"

@class KCVideo;

@interface KC_BaseView : UINavigationController <KCVideoProcessDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) KCVideo * latestVideo;
@property (nonatomic, retain) UITabBarController * tabBarController;
// TODO: This exposure makes for confusing code elsewhere. Should fix!
@property (nonatomic, retain) VideoTableViewController * watchView;

- (id)initWithVideo:(KCVideo *)video
           viewMode:(KC_VIEW_MODE)viewMode
             params:(NSDictionary *)params
           assetMap:(KCUiAssetMap *)assetMap;

- (void)doneTapped;
- (void)setSelectedTab:(NSUInteger)index;
- (void)userStartedShareProcess;
- (void)disableTabBarItems;
- (void)enableTabBarItems;
@end
