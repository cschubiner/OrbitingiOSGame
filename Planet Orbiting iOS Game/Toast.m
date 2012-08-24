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
        fadeOutTime = .5;
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
        toPos = CGPointMake(view.boundingBox.size.width/2, view.boundingBox.size.height - toastView.boundingBox.size.height/2+1);
    } else {
        fromPos = CGPointMake(view.boundingBox.size.width/2, -toastView.boundingBox.size.height/2);
        toPos = CGPointMake(view.boundingBox.size.width/2, toastView.boundingBox.size.height/2-1);
    }
    
    toastView.position = fromPos;
    
    id moveIn = [CCMoveTo actionWithDuration:fadeInTime position:toPos];
    id wait = [CCDelayTime actionWithDuration:waitTime];
    id moveOut = [CCMoveTo actionWithDuration:fadeOutTime position:fromPos];
    id removeLoadingLayer = [CCCallBlock actionWithBlock:(^{
        [view removeChild:toastView cleanup:YES];
    })];
    id actions = [CCSequence actions:moveIn, wait, moveOut, removeLoadingLayer, nil];
    [toastView runAction:actions];
    toastView.zOrder = INT_MAX;
    
    /*id fadeIn = [CCFadeIn actionWithDuration:1];
    id fadeOut = [CCFadeOut actionWithDuration:1];
    id actions2 = [CCSequence actions:fadeIn, wait, fadeOut, nil];
    [toastView runAction:actions2];*/
}

-(CCLayer*)makeToastView:(NSString*)a_text fontSize:(float)a_fontSize{
    
    CCSprite* background = [CCSprite spriteWithFile:@"missionsPopup.png"];
    
    CCSprite* ind0 = [CCSprite spriteWithFile:@"missioncomplete.png"];
    ind0.position = ccp(-background.boundingBox.size.width/2 + 30, 0);
    
    CCLabelTTF* label = [CCLabelTTF labelWithString:a_text dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    label.position = ccp(label.boundingBox.size.width/2 - background.boundingBox.size.width/2 + 60, 0);
    
    
    CCLayer* layerToAdd = [[CCLayer alloc] init];
    [layerToAdd setContentSize:CGSizeMake(background.boundingBox.size.width, background.boundingBox.size.height)];
    [layerToAdd addChild:background];
    [layerToAdd addChild:ind0];
    [layerToAdd addChild:label];
    
    
    return layerToAdd;
}

@end
