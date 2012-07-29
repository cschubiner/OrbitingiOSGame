//
//  Light.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 7/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"

@interface Light : CCNode

@property (nonatomic, assign) CCSprite* sprite;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint acceleration;

@end
