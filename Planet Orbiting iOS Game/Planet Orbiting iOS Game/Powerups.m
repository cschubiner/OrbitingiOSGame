//
//  Powerups.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Powerups.h"

@implementation Powerups

@synthesize hasAsteroidImmunity;

static Powerups *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([Powerups class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[Powerups alloc] init];
            sharedInstance.hasAsteroidImmunity = false;
        }
    }
    return sharedInstance;
}

@end