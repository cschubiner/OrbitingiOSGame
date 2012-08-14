//
//  Light.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 7/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"
#import "UpgradeValues.h"

@interface Light : CCNode

@property (nonatomic, retain) CCSprite* sprite;
@property (nonatomic) int stage; //0=far away, 1=close, 2=wrapping
@property (nonatomic) bool hasPutOnLight;
@property (nonatomic) float score;
@property (nonatomic) float timeLeft;
@property (nonatomic) float scoreVelocity;
@property (nonatomic) float distanceFromPlayer;

@end
