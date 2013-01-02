//
//  KC_ShareMessageDelegate.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/25/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KC_ShareMessageDelegate <NSObject>

-(void)currentMessageState:(NSString *)message;

@end
