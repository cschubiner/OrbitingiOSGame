//
//  UpgradeCell.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CCLayer.h"
#import "UpgradeItem.h"
#import "cocos2d.h"

@interface UpgradeCell : CCLayer

@property (nonatomic, retain) CCLabelTTF *levelLabel;
@property (nonatomic) int index;

- (id)initWithUpgradeItem:(UpgradeItem*)item;

@end