//
//  UpgradeManager.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeManager.h"

@implementation UpgradeManager

@synthesize upgradeItems;

static UpgradeManager *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([UpgradeManager class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[UpgradeManager alloc] init];
        }
    }
    return sharedInstance;
}

@end