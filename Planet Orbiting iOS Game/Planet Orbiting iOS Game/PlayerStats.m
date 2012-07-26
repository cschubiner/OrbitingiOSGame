//
//  PlayerStats.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "PlayerStats.h"

@implementation PlayerStats {
    int totalPlays;
}

static PlayerStats *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([PlayerStats class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[PlayerStats alloc] init];
        }
    }
    return sharedInstance;
}

- (void)addPlay {
    totalPlays += 1;
}

- (int)getPlays {
    return totalPlays;
}

- (void)setPlays:(int)plays {
    totalPlays = plays;
}

@end