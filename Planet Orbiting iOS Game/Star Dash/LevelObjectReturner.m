//
//  LevelObjectReturner.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "LevelObjectReturner.h"

@implementation LevelObjectReturner
@synthesize type,pos,scale;

-(id) initWithType:(enum LevelObjectTypes) typeInputted position:(CGPoint)posI scale:(float)scaleI{
    // always call "super" init
    // Apple recommends to re-assign "self" with the "super" return value
    if( (self=[super init])) {
        [self setType:typeInputted];
        [self setPos:posI];
        [self setScale:scaleI];
    }
    return self;
}
@end
