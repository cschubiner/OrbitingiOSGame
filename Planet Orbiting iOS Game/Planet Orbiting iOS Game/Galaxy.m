//
//  Galaxy.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 8/2/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "Galaxy.h"
#import "AppDelegate.h"

@implementation Galaxy
@synthesize number,segments,backgroundSprite,name,numberOfDifferentPlanetsDrawn,spriteSheet,optimalPlanetsInThisGalaxy,percentTimeToAddUponGalaxyCompletion;

-(id)initWithSegments:(NSArray *)levelsegments{
    if ((self = [super init])) {
        segments = levelsegments;
        self.number = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getGalaxyCounter];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setGalaxyCounter:self.number+1];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"galaxy%d.pvr.ccz",self.number]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"galaxy%d.plist",self.number]];
        optimalPlanetsInThisGalaxy = 23;
        percentTimeToAddUponGalaxyCompletion = .35;
    }
    return self;
}
@end
