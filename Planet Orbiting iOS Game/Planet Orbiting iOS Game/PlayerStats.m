//
//  PlayerStats.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "PlayerStats.h"

const int highScoreLimit = 4;

@implementation PlayerStats {
    int totalPlays;
    NSMutableArray *highScores;
}

static PlayerStats *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([PlayerStats class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[PlayerStats alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
        highScores = [[NSMutableArray alloc] init];
        for (int i = 0; i < highScoreLimit; i++) {
            [highScores addObject:[NSNumber numberWithInt:0]];
        }
    }
    return self;
}

- (void)addPlay {
    totalPlays += 1;
}

- (int)getPlays {
    return totalPlays;
}

- (void)setPlays:(int)plays {
    totalPlays = plays;
}

- (void)addScore:(int)score {
    NSNumber *newScore = [[NSNumber alloc] initWithInt:score];
    [highScores addObject:newScore];
        [newScore release];
    
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [highScores sortUsingDescriptors:[NSMutableArray arrayWithObject:highestToLowest]];
    
    if ([highScores count] > highScoreLimit) {
        [highScores removeObjectAtIndex:[highScores count] - 1];
    }

}

- (NSMutableArray *)getScores {
    return highScores;
}

- (void)setScores:(NSMutableArray *)scores {
    highScores = scores;
}

@end