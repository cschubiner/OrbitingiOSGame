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
@property (nonatomic) float absoluteMinTimeDilation;
@property (nonatomic) int hasDoubleCoins;



+ (id)sharedInstance;

@end