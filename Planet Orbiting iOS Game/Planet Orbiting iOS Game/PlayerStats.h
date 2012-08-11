//
//  PlayerStats.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDGameKitHelper.h"

@interface PlayerStats : NSObject

+ (id)sharedInstance;

- (void)addPlay;
- (int)getPlays;
- (void)setPlays:(int)plays;
- (void)addScore:(int)score withName:(NSString *)name;
- (NSMutableArray *)getScores;
- (NSMutableDictionary *)getKeyValuePairs;
- (void)setScores:(NSMutableArray *)scores;
- (void)setKeyValuePairs:(NSMutableDictionary *)dict;
- (BOOL)isHighScore:(int)score;

@end