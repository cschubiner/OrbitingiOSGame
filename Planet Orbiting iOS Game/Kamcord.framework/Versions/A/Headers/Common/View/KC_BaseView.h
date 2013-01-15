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

@class KCVideo;

@interface KC_BaseView : UINavigationController <KCVideoProcessDelegate>

@property (nonatomic, retain) KCVideo * latestVideo;

- (id)initWithVideo:(KCVideo *)video
         useOldView:(BOOL)oldView;

@end
