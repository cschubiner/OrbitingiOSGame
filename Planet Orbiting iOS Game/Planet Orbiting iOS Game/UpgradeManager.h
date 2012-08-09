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

+ (id)sharedInstance;

@end
