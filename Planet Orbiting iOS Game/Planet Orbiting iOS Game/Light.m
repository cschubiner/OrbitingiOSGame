//
//  Light.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 7/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Light.h"
@implementation Light

@synthesize sprite,timeLeft, stage, hasPutOnLight, scoreVelocity, distanceFromPlayer;



-(id)init {
    if (self=[super init]) {
        timeLeft = [[UpgradeValues sharedInstance] maxBatteryTime];
    }
    return self;
}
@end
