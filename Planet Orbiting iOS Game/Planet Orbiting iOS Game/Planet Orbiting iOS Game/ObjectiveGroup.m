//
//  ObjectiveGroup.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

//#import "ObjectiveGroup.h"
#import "ObjectiveHeader.h"

@implementation ObjectiveGroup

@synthesize objectiveItems, scoreMult, starReward;

-(id)initWithScoreMult:(float) a_scoreMult starReward:(int)a_starReward item0:(ObjectiveItem*)a_item0 item1:(ObjectiveItem*)a_item1 item2:(ObjectiveItem*)a_item2 {
    if (self = [super init]) {
        self.scoreMult = a_scoreMult;
        self.starReward = a_starReward;
        
        self.objectiveItems = [[NSMutableArray alloc] initWithObjects:
                               a_item0,
                               a_item1,
                               a_item2, nil];
    }
    return self;
}

@end