//
//  UpgradeValues.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeValues.h"

@implementation UpgradeValues

// values set in initUpgradedVariables in gameplaylayer.m
@synthesize asteroidImmunityDuration, coinMagnetDuration, autopilotDuration, absoluteMinTimeDilation, hasDoubleCoins, maxBatteryTime, hasAsteroidArmor, hasAutoPilot, hasStarMagnet, hasStartPowerup, hasHeadStart, hasBlueShip, hasGoldShip, hasGreenShip, hasOrangeShip, hasPinkShip, hasPurpleShip, hasRedShip, hasPinkStars;

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