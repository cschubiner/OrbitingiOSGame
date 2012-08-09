//
//  UpgradeItem.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeItem.h"

@implementation UpgradeItem

@synthesize description, hasLevels, icon, level, price, title;

-(id)initWithTitle:(NSString*)tit description:(NSString*)desc icon:(NSString*)ic price:(int)pr hasLevels:(bool)hasLevs level:(int)lvl {
    if (self = [super init]) {
        self.title = tit;
        self.description = desc;
        self.icon = ic;
        self.price = pr;
        self.hasLevels = hasLevs;
        self.level = lvl;
    }
    return self;
}

@end