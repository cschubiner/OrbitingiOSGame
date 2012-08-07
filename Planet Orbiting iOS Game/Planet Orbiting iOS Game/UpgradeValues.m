//
//  UpgradeValues.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeValues.h"

@implementation UpgradeValues

@synthesize asteroidImmunityDuration, coinMagnetDuration;

static UpgradeValues *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([UpgradeValues class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[UpgradeValues alloc] init];
        }
    }
    return sharedInstance;
}

@end
