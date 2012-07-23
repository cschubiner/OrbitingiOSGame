//
//  CameraObject.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CameraObject : CCNode {
    float radius;
}

@property (nonatomic,retain) CCSprite *sprite;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint acceleration;
@property (nonatomic) int number;
@property (nonatomic) bool alive;
@property (nonatomic) bool isBeingDrawn;
@property (nonatomic) bool hasExploded;


-(CGPoint)position;
-(void)setPosition:(CGPoint)position;
-(CGPoint)getPositionOnScreen:(CCLayer*)layerObjectIsOn;
-(float)radius;
-(CGRect)rect;
-(CGRect)rectOnScreen:(CCLayer*)layerObjectIsOn;
@end