//
//  UpgradeItem.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeItem.h"

@implementation UpgradeItem

- (id)initWithTitle:(NSString *)cTitle description:(NSString *)cDescription exclusive:(BOOL)cExclusive equipped:(BOOL)cEquipped {
    if (self = [super init]) {
        self.title = cTitle;
        self.description = cDescription;
        self.exclusive = cExclusive;
        self.equipped = cEquipped;
    }
    return self;
}

@end