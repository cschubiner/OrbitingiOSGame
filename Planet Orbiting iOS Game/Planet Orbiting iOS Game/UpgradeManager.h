//
//  UpgradeManager.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeManager : NSObject

@property (nonatomic, retain) NSMutableArray* upgradeItems;
@property (nonatomic) int buttonPushed;

+ (id)sharedInstance;

- (void)setUpgradeIndex:(int)index purchased:(BOOL)pPurchased equipped:(BOOL)pEquipped;
- (void)setUpgradeIndex:(int)index purchased:(BOOL)pPurchased;
- (void)setUpgradeIndex:(int)index equipped:(BOOL)pEquipped;

@end