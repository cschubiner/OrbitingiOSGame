//
//  UpgradeCell.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UpgradeCell.h"

@implementation UpgradeCell

@synthesize index;

- (id)initWithUpgradeItem:(UpgradeItem*)item {
    if (self = [super init]) {
        UpgradeCell* aCell = [[UpgradeCell alloc] init];
        
        
        CCSprite* backgroundSprite = [CCSprite spriteWithFile:@"cellBackground.png"];
        [aCell addChild:backgroundSprite];
        [backgroundSprite setPosition:ccp(backgroundSprite.width/2, -backgroundSprite.height/2)];
        
        
        CCSprite* upgradeSprite = [CCSprite spriteWithFile:item.icon];
        [upgradeSprite setScale:.5];
        [aCell addChild:upgradeSprite];
        [upgradeSprite setPosition:ccp(upgradeSprite.width/2+5, -backgroundSprite.height/2)];
        
        
        CCLabelTTF* hello = [CCLabelTTF labelWithString:item.title fontName:@"Marker Felt" fontSize:24];
        [aCell addChild: hello];
        [hello setPosition:ccp(90 + [hello boundingBox].size.width/2, -25)];
        
        CCLabelTTF* hello2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level %d", item.level] fontName:@"Marker Felt" fontSize:18];
        [aCell addChild: hello2];
        [hello2 setPosition:ccp(90 + [hello2 boundingBox].size.width/2, -58)];
        
        CCSprite* starSprite = [CCSprite spriteWithFile:@"star1.png"];
        [starSprite setScale:.16];
        [aCell addChild:starSprite];
        [starSprite setPosition:ccp(480-starSprite.width/2-8, -57)];
        
        CCLabelTTF* hello3 = [CCLabelTTF labelWithString:[self commaInt:item.price] fontName:@"Marker Felt" fontSize:18];
        [aCell addChild: hello3];
        [hello3 setPosition:ccp(480 - 37 - [hello3 boundingBox].size.width/2, -58)];
        
        
        [aCell setContentSize:CGSizeMake(480, 80)];
        
    }
    return self;
}



- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}


@end
