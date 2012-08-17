//
//  Toast.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/16/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Toast : NSObject

@property (nonatomic, retain) CCLayer* view;
@property (nonatomic, retain) NSString* text;
@property (nonatomic) float fontSize;
@property (nonatomic) bool fromTop;
@property (nonatomic) float fadeInTime;
@property (nonatomic) float waitTime;
@property (nonatomic) float fadeOutTime;

-(id)initWithView:(CCLayer*)a_view text:(NSString*)a_text;
-(void)showToast;

@end
