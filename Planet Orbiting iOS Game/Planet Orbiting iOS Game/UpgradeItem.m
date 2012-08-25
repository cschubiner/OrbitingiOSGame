//
//  UpgradeItem.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeItem.h"

@implementation UpgradeItem

- (id)initWithTitle:(NSString *)cTitle description:(NSString *)cDescription price:(int)cPrice type:(int)cType purchased:(BOOL)cPurchased equipped:(BOOL)cEquipped number:(int)a_number {
    if (self = [super init]) {
        self.title = cTitle;
        self.description = cDescription;
        self.price = cPrice;
        self.type = cType;
        self.purchased = cPurchased;
        self.equipped = cEquipped;
        self.number = a_number;
    }
    return self;
}

@end