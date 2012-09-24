//
//  Coin.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@synthesize isAlive, speed, movingSprite,isTargettingScoreLabel;

-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        isAlive = true;
        speed = 0;
	}
	return self;
}


@end