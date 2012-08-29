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
@property (nonatomic) bool hasPinkStars;
@property (nonatomic) bool hasGreenShip;
@property (nonatomic) bool hasBlueShip;
@property (nonatomic) bool hasGoldShip;
@property (nonatomic) bool hasOrangeShip;
@property (nonatomic) bool hasRedShip;
@property (nonatomic) bool hasPurpleShip;
@property (nonatomic) bool hasPinkShip;
@property (nonatomic) bool hasGreenTrail;
@property (nonatomic) bool hasBlueTrail;
@property (nonatomic) bool hasGoldTrail;
@property (nonatomic) bool hasOrangeTrail;
@property (nonatomic) bool hasRedTrail;
@property (nonatomic) bool hasPurpleTrail;
@property (nonatomic) bool hasPinkTrail;
@property (nonatomic) bool hasBlackTrail;
@property (nonatomic) bool hasBrownTrail;

+ (id)sharedInstance;

@end