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
@synthesize number,segments;

-(id)initWithSegments:(NSArray *)levelsegments{
    if ((self = [super init])) {
        segments = levelsegments;
        self.number = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getGalaxyCounter];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setGalaxyCounter:self.number+1];
        [segments retain];
    }
    return self;
}
@end
