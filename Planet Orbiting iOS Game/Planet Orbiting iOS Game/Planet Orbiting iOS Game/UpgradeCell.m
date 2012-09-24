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
        
        CCSprite* upgradeSprite ;//= [CCSprite spriteWithFile:@"missioncomplete.png"];
        if (item.equipped)
            upgradeSprite = [CCSprite spriteWithFile:@"equipped.png"];
        else if (item.purchased)
            upgradeSprite = [CCSprite spriteWithFile:@"purchased.png"];
        else
            upgradeSprite = [CCSprite spriteWithFile:@"notpurchased.png"];
        
        
        [self addChild:upgradeSprite];
        [upgradeSprite setPosition:ccp(30, -27)];
        
        CCLabelTTF* hello = [CCLabelTTF labelWithString:item.title dimensions:CGSizeMake(480-60-100, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
        [self addChild:hello];
        [hello setAnchorPoint:ccp(0, .5)];
        hello.position = ccp(60, -27);
        
        
        if (!(item.number == 3 || item.number ==  11 || item.number == 12 || item.number == 13 || item.number == 14 || item.number == 15 || item.number == 16)) {
            coinSprite = [CCSprite spriteWithFile:@"staricon.png"];
            [coinSprite setScale:.45];
            [self addChild:coinSprite];
            [coinSprite setPosition:ccp(480-18, -25)];
            
            
            priceLabel = [CCLabelTTF labelWithString:[self commaInt:item.price]  fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
            [self addChild: priceLabel];
            [priceLabel setPosition:ccp(480 - 33 - [priceLabel boundingBox].size.width/2, -27)];
        } else {
            priceLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"$%.2f", ((float)item.price)/100] fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
            [self addChild: priceLabel];
            [priceLabel setPosition:ccp(480 - 33 - [priceLabel boundingBox].size.width/2, -27)];
        }
        
        [self setContentSize:CGSizeMake(480, 55)];
    }
    return self;
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

@end