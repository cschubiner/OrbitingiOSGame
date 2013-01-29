//
//  PlayerStats.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "PlayerStats.h"

const int highScoreLimit = 20;

@implementation PlayerStats {
    int totalPlays;
    NSMutableArray *highScores;
    NSMutableArray *rawScores;
    NSMutableArray *rawNames;
    NSMutableDictionary *keyValuePairs;
}

@synthesize isMuted, recentName, hasWatchedVideo;

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
        rawScores = [[NSMutableArray alloc] init];
        rawNames = [[NSMutableArray alloc] init];
        keyValuePairs = [[NSMutableDictionary alloc] init];
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

- (void)addScore:(int)score withName:(NSString *)name {
    if (!name||[name isEqualToString:@""])
        name = @"PLAYER";
    //NSLog(@"a1");
    NSNumber *newScore = [[NSNumber alloc] initWithInt:score];
    [highScores addObject:newScore];
    //NSLog(@"a2");
    [rawScores addObject:newScore];
    //NSLog(@"a3a");
    [rawNames addObject:name];
    //NSLog(@"a3b");
    //NSLog(@"a4");
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [highScores sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    //   NSLog(@"a5");
    if ([highScores count] > highScoreLimit) {
        [highScores removeObjectAtIndex:[highScores count] - 1];
    }
    //NSLog(@"a6");
    NSString *scoreString = [NSString stringWithFormat:@"%d", score];
    //  NSLog(@"a7");
    [keyValuePairs setObject:name forKey:scoreString];
}

- (NSMutableArray *)getScores {
    return highScores;
}

- (NSMutableDictionary *)getKeyValuePairs {
    return keyValuePairs;
}

- (void)setScores:(NSMutableArray *)scores {
    highScores = scores;
}

- (void)setKeyValuePairs:(NSMutableDictionary *)dict {
    keyValuePairs = dict;
}

- (BOOL)isHighScore:(int)score {
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [highScores sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    int count = [highScores count];
    int lowestValue = [[highScores objectAtIndex:count-1] intValue];
    return score > lowestValue;
}

@end