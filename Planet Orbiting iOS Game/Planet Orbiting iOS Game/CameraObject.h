//
//  CameraObject.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CameraObject : CCNode {

}

@property (nonatomic,retain) CCSprite *sprite;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint acceleration;
@property (nonatomic) int number; //or "number", as we used to call it in copter crush...
@property (nonatomic) bool alive;

-(CGPoint)position;
-(void)setPosition:(CGPoint)position;
-(CGPoint)getPositionOnScreen:(CCLayer*)layerObjectIsOn;

@end