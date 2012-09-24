//
//  PowerupManager.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "PowerupManager.h"

@implementation PowerupManager

@synthesize
numberOfMagnet,
numberOfImmunity;

static PowerupManager *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([PowerupManager class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[PowerupManager alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        numberOfMagnet = 0;
        numberOfImmunity = 0;
    }
    return self;
}

- (void)addMagnet {
    numberOfMagnet += 1;
}

- (void)addImmunity {
    numberOfImmunity += 1;
}

- (void)subtractMagnet {
    numberOfMagnet -= 1;
}

- (void)subtractImmunity {
    numberOfImmunity -= 1;
}

- (int)numMagnet {
    return numberOfMagnet;
}

- (int)numImmunity {
    return numberOfImmunity;
}

@end