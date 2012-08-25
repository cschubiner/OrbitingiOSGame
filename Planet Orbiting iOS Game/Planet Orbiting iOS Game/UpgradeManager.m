//
//  UpgradeManager.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeManager.h"
#import "UpgradeItem.h"

@implementation UpgradeManager

@synthesize upgradeItems, buttonPushed;

static UpgradeManager *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([UpgradeManager class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[UpgradeManager alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.upgradeItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setUpgradeIndex:(int)index purchased:(BOOL)pPurchased equipped:(BOOL)pEquipped {
    UpgradeItem *item = [self.upgradeItems objectAtIndex:index];
    [item setPurchased:pPurchased];
    [item setEquipped:pEquipped];
}

- (void)setUpgradeIndex:(int)index purchased:(BOOL)pPurchased {
    UpgradeItem *item = [self.upgradeItems objectAtIndex:index];
    [item setPurchased:pPurchased];
}

- (void)setUpgradeIndex:(int)index equipped:(BOOL)pEquipped {
    UpgradeItem *item = [self.upgradeItems objectAtIndex:index];
    [item setEquipped:pEquipped];
}

@end