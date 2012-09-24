//
//  LevelObjectReturner.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "LevelObjectReturner.h"

@implementation LevelObjectReturner
@synthesize type,pos,scale,canBeFlipped;

-(id) initWithType:(enum LevelObjectTypes) typeInputted position:(CGPoint)posI scale:(float)scaleI{
    return [self initWithType:typeInputted position:posI scale:scaleI canBeFlipped:YES];
}

-(id)initWithType:(enum LevelObjectTypes)typeInputted position:(CGPoint)posI scale:(float)scaleI canBeFlipped:(bool)shouldFlip {
    // always call "super" init
    // Apple recommends to re-assign "self" with the "super" return value
    if( (self=[super init])) {
        [self setType:typeInputted];
        [self setPos:posI];
        [self setScale:scaleI];
        [self setCanBeFlipped:shouldFlip];
    }
    return self;
}
@end
