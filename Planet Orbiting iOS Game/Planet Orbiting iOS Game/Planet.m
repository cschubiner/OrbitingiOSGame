//
//  Planet.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "Planet.h"

@implementation Planet

@synthesize forceExertingOnPlayer,mass;

-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        mass = 1;
	}
	return self;
}

- (float)radius {
    radius = MAX([[self sprite] width],[[self sprite] width])/2;
    return radius;
}

@end