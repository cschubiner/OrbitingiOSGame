//
//  HintTextView.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/18/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (void)dealloc;

@end
