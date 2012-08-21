//
//  UpgradeCell.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeCell.h"

@implementation UpgradeCell

@synthesize index, levelLabel, priceLabel, coinSprite;

- (id)initWithUpgradeItem:(UpgradeItem*)item {
    if (self = [super init]) {
        CCSprite* backgroundSprite = [CCSprite spriteWithFile:@"upgradeCellSex.png"];
        [self addChild:backgroundSprite];
        [backgroundSprite setPosition:ccp(backgroundSprite.width/2, -backgroundSprite.height/2)];
        
        CCSprite* upgradeSprite = [CCSprite spriteWithFile:@"missioncomplete.png"];
        [upgradeSprite setScale:.5];
        [self addChild:upgradeSprite];
        [upgradeSprite setPosition:ccp(45, -40)];
        
        CCLabelTTF* hello = [CCLabelTTF labelWithString:item.title fontName:@"Marker Felt" fontSize:24];
        [self addChild: hello];
        [hello setPosition:ccp(90 + [hello boundingBox].size.width/2, -25)];
        
        coinSprite = [CCSprite spriteWithFile:@"star1.png"];
        [coinSprite setScale:.16];
        [self addChild:coinSprite];
        [coinSprite setPosition:ccp(480-coinSprite.width/2-8, -57)];
        
        priceLabel = [CCLabelTTF labelWithString:[self commaInt:item.price]  fontName:@"Marker Felt" fontSize:18];
        [self addChild: priceLabel];
        [priceLabel setPosition:ccp(480 - 37 - [priceLabel boundingBox].size.width/2, -58)];
        
        [self setContentSize:CGSizeMake(480, 80)];
    }
    return self;
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

@end