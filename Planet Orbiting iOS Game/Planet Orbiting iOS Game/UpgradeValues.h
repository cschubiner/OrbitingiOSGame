//
//  UpgradeValues.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpgradeValues : NSObject

// values set in initUpgradedVariables in gameplaylayer.m
@property (nonatomic) float asteroidImmunityDuration;
@property (nonatomic) float coinMagnetDuration;
@property (nonatomic) float autopilotDuration;
@property (nonatomic) float absoluteMinTimeDilation;
@property (nonatomic) bool hasDoubleCoins;
@property (nonatomic) float maxBatteryTime;
@property (nonatomic) bool hasStarMagnet;
@property (nonatomic) bool hasAsteroidArmor;
@property (nonatomic) bool hasAutoPilot;
@property (nonatomic) bool hasStartPowerup;
@property (nonatomic) bool hasHeadStart;

+ (id)sharedInstance;

@end