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
        CCSprite* backgroundSprite = [CCSprite spriteWithFile:@"cellBackground.png"];
        [self addChild:backgroundSprite];
        [backgroundSprite setPosition:ccp(backgroundSprite.width/2, -backgroundSprite.height/2)];
        
        CCSprite* upgradeSprite = [CCSprite spriteWithFile:item.icon];
        [upgradeSprite setScale:.5];
        [self addChild:upgradeSprite];
        [upgradeSprite setPosition:ccp(45, -40)];
        
        CCLabelTTF* hello = [CCLabelTTF labelWithString:item.title fontName:@"Marker Felt" fontSize:24];
        [self addChild: hello];
        [hello setPosition:ccp(90 + [hello boundingBox].size.width/2, -25)];
        
        
        NSString* strToUse;
        if ([item.prices count] == 1) {
            if (item.level == 0)
                strToUse = @"Inactive";
            else
                strToUse = @"Active";
        } else {
            strToUse = [NSString stringWithFormat:@"Level %d", item.level];
        }
        
        
        levelLabel = [CCLabelTTF labelWithString:strToUse fontName:@"Marker Felt" fontSize:18];
        if (item.level == [item.prices count])
            [levelLabel setColor:ccGREEN];
        [self addChild: levelLabel];
        [levelLabel setPosition:ccp(90 + [levelLabel boundingBox].size.width/2, -58)];
        
        if (item.level < [item.prices count]) {
            coinSprite = [CCSprite spriteWithFile:@"star1.png"];
            [coinSprite setScale:.16];
            [self addChild:coinSprite];
            [coinSprite setPosition:ccp(480-coinSprite.width/2-8, -57)];
            
            priceLabel = [CCLabelTTF labelWithString:[self commaInt:[[item.prices objectAtIndex:item.level] intValue]] fontName:@"Marker Felt" fontSize:18];
            [self addChild: priceLabel];
            [priceLabel setPosition:ccp(480 - 37 - [priceLabel boundingBox].size.width/2, -58)];
        }
        
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