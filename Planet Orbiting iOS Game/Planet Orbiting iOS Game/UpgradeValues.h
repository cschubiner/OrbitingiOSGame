//
//  UpgradeValues.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpgradeValues : NSObject

@property (nonatomic) float asteroidImmunityDuration;
@property (nonatomic) float coinMagnetDuration;

+ (id)sharedInstance;



@end
