//
//  PlayerStats.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerStats : NSObject

+ (id)sharedInstance;

- (void)addPlay;
- (int)getPlays;
- (void)setPlays:(int)plays;
- (void)addScore:(int)score;
- (NSMutableArray *)getScores;
- (void)setScores:(NSMutableArray *)scores;

@end