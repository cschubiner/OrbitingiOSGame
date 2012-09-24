//
//  Player.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize thrustEndPoint,thrustBeginPoint,mass,isInZone,coins,moveAction,rotationAtLastThrust,positionAtLastThrust, currentPowerup;

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        mass = 1;
        coins = 0;
        currentPowerup = nil;
	}
	return self;
}

- (float)radius {
    radius = MAX([[self sprite] height],[[self sprite] width])/2;
    return radius;
}

@end
