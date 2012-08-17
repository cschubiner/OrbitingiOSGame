//
//  Toast.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/16/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Toast.h"

@implementation Toast {
    CCLayer* toastView;
}

@synthesize view, text, fontSize, fromTop, fadeInTime, waitTime, fadeOutTime;

-(id)initWithView:(CCLayer*)a_view text:(NSString*)a_text {
    if (self = [super init]) {
        view = a_view;
        text = a_text;
        fontSize = 20;
        fromTop = true;
        fadeInTime = .5;
        waitTime = 3;
        fadeOutTime = 1.5;
    }
    return self;
}

-(void)showToast {
    toastView = [self makeToastView:text fontSize:(float)fontSize];
    
    [view addChild:toastView];
    
    CGPoint fromPos;
    CGPoint toPos;
    if (fromTop) {
        fromPos = CGPointMake(view.boundingBox.size.width/2, view.boundingBox.size.height + toastView.boundingBox.size.height/2);
        toPos = CGPointMake(view.boundingBox.size.width/2, view.boundingBox.size.height - toastView.boundingBox.size.height/2);
    } else {
        fromPos = CGPointMake(view.boundingBox.size.width/2, -toastView.boundingBox.size.height/2);
        toPos = CGPointMake(view.boundingBox.size.width/2, toastView.boundingBox.size.height/2);
    }
    
    toastView.position = fromPos;
    
    id moveIn = [CCMoveTo actionWithDuration:.5 position:toPos];
    id wait = [CCDelayTime actionWithDuration:1];
    id moveOut = [CCMoveTo actionWithDuration:2 position:fromPos];
    id actions = [CCSequence actions:moveIn, wait, moveOut, nil];
    [toastView runAction:actions];
    toastView.zOrder = INT_MAX;
    
    /*id fadeIn = [CCFadeIn actionWithDuration:1];
    id fadeOut = [CCFadeOut actionWithDuration:1];
    id actions2 = [CCSequence actions:fadeIn, wait, fadeOut, nil];
    [toastView runAction:actions2];*/
}

-(CCLayer*)makeToastView:(NSString*)a_text fontSize:(float)a_fontSize{
    
    CCSprite* background = [CCSprite spriteWithFile:@"OneByOne.png"];
    [background setColor:ccc3(137, 137, 137)];
    
    CCLabelTTF* label = [CCLabelTTF labelWithString:a_text fontName:@"Marker Felt" fontSize:a_fontSize];
    
    label.color = ccc3(255, 255, 255);
    
    label.position = CGPointMake(0, 0);
    
    
    CCLayer* layerToAdd = [[CCLayer alloc] init];
    [layerToAdd setContentSize:CGSizeMake(480, label.boundingBox.size.height)];
    background.scaleX = 480;
    background.scaleY = label.boundingBox.size.height;
    [layerToAdd addChild:background];
    [layerToAdd addChild:label];
    
    
    return layerToAdd;
}

@end
