//
//  ShareView.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/28/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCViewController.h"
#import "KC_ShareMessageDelegate.h"
#import "KCVideoProcessingAndShareManager.h"

@class HintTextView;

@interface ShareView : KCViewController <UITextViewDelegate, KCShareDelegate>

- (id)initWithTitle:(NSString *)title
               text:(NSString *)text
           delegate:(id)delegate;

- (void) dealloc;

@end
