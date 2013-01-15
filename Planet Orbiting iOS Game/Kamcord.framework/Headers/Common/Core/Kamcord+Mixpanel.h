//
//  Kamcord+Mixpanel.h
//  cocos2d-ios
//
//  Created by Matthew Zitzmann on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kamcord.h"
#import "KCAnalytics.h"

@class MixpanelAPI;

@interface Kamcord (Mixpanel)

@property (nonatomic, retain) MixpanelAPI * mixpanel;

@end
