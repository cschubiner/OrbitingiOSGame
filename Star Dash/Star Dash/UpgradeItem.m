//
//  UpgradeItem.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeItem.h"

@implementation UpgradeItem

@synthesize description, icon, level, prices, title;

-(id)initWithTitle:(NSString*)tit description:(NSString*)desc icon:(NSString*)ic prices:(NSMutableArray*)prs level:(int)lvl {
    if (self = [super init]) {
        self.title = tit;
        self.description = desc;
        self.icon = ic;
        self.prices = prs;
        self.level = lvl;
    }
    return self;
}

@end