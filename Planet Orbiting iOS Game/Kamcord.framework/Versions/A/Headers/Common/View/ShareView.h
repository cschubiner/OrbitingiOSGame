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
#import "MainView.h"
#import "HintTextView.h"
#import "KCVideoProcessingAndShareManager.h"


@interface ShareView : KCViewController <UITextViewDelegate, KCShareDelegate>

@property (assign, nonatomic) KC_BaseView *parent;
@property (retain, nonatomic) HintTextView *textView; 

- (id)initWithTitle:(NSString *)title
             parent:(KC_BaseView *)parent
               text:(NSString *)text
           delegate:(id)delegate;

- (void) dealloc;

@end
