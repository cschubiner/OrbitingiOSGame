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
numMagnet,
numBeast;

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
        numMagnet = 0;
        numBeast = 0;
    }
    return self;
}

- (void)addMagnet {
    numMagnet += 1;
}

- (void)addBeast {
    numBeast += 1;
}

@end